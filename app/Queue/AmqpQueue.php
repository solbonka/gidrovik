<?php

namespace App\Queue;

use App\Queue\Jobs\AmqpJob;
use Illuminate\Contracts\Queue\Job as JobContract;
use Illuminate\Contracts\Queue\Queue as QueueContract;
use Illuminate\Queue\Queue;
use Illuminate\Support\Carbon;
use PhpAmqpLib\Channel\AbstractChannel;
use PhpAmqpLib\Connection\AbstractConnection;
use PhpAmqpLib\Message\AMQPMessage;

use function Illuminate\Support\enum_value;

class AmqpQueue extends Queue implements QueueContract
{
    /**
     * The AMQP connection instance.
     *
     * @var AbstractConnection
     */
    protected $connection;

    /**
     * The AMQP channel instance.
     *
     * @var AbstractChannel
     */
    protected $channel;

    /**
     * The queue name.
     *
     * @var string
     */
    protected $queue;

    /**
     * The name of the default queue.
     *
     * @var string
     */
    protected $default;

    /**
     * The number of seconds before a job should be retried.
     *
     * @var int
     */
    protected $retryAfter;

    /**
     * Create a new AMQP queue instance.
     */
    public function __construct(
        AbstractConnection $connection,
        AbstractChannel $channel,
        string $queue,
        int $retryAfter = 60,
        string $connectionName = 'amqp'
    ) {
        $this->connection = $connection;
        $this->channel = $channel;
        $this->queue = $queue;
        $this->default = $queue;
        $this->retryAfter = $retryAfter;
        $this->connectionName = $connectionName;
    }

    /**
     * Get the size of the queue.
     */
    public function size($queue = null): int
    {
        $queue = $this->getQueue($queue);

        $result = $this->channel->queue_declare(
            queue: $queue,
            passive: true,
        );

        return (int) $result['message_count'];
    }

    /**
     * Get the number of pending jobs.
     */
    public function pendingSize($queue = null): int
    {
        return $this->size($queue);
    }

    /**
     * Get the number of delayed jobs.
     */
    public function delayedSize($queue = null): int
    {
        return 0;
    }

    /**
     * Get the number of reserved jobs.
     */
    public function reservedSize($queue = null): int
    {
        return 0;
    }

    /**
     * Get the creation timestamp of the oldest pending job.
     */
    public function creationTimeOfOldestPendingJob($queue = null)
    {
        return null;
    }

    /**
     * Get the queue name for the given queue.
     */
    public function getQueue($queue = null): string
    {
        return $this->resolveQueue(enum_value($queue) ?: $this->default);
    }

    /**
     * Push a new job onto the queue.
     */
    public function push($job, $data = '', $queue = null)
    {
        return $this->enqueueUsing(
            $job,
            $this->createPayload($job, $this->getQueue($queue), $data),
            $queue,
            null,
            function ($payload, $queue) {
                return $this->pushToQueue($queue, $payload);
            }
        );
    }

    /**
     * Push a raw payload onto the queue.
     */
    public function pushRaw($payload, $queue = null, array $options = [])
    {
        return $this->pushToQueue($this->getQueue($queue), $payload);
    }

    /**
     * Push a new job onto the queue after (n) seconds.
     */
    public function later($delay, $job, $data = '', $queue = null)
    {
        $queue = $this->getQueue($queue);

        return $this->enqueueUsing(
            $job,
            $this->createPayload($job, $queue, $data),
            $queue,
            $delay,
            function ($payload, $queue) use ($delay) {
                $availableAt = Carbon::now()->addSeconds($this->secondsUntil($delay))->getTimestamp();

                $message = new AMQPMessage(
                    body: $payload,
                    properties: [
                        'delivery_mode' => 2,
                        'headers' => [
                            'x-delay' => (int) $this->secondsUntil($delay) * 1000,
                            'x-available-at' => $availableAt,
                        ],
                    ],
                );

                $this->channel->basic_publish(
                    msg: $message,
                    exchange: '',
                    routing_key: $queue,
                );
            }
        );
    }

    /**
     * Pop the next job off of the queue.
     */
    public function pop($queue = null): ?JobContract
    {
        $queue = $this->getQueue($queue);

        $message = $this->channel->basic_get(
            queue: $queue,
            no_ack: false,
        );

        if (! $message) {
            return null;
        }

        $body = $message->getBody();
        $payload = json_decode($body, true);

        if (! is_array($payload)) {
            $message->ack();

            return null;
        }

        return new AmqpJob(
            container: $this->container,
            queue: $this,
            message: $message,
            queueName: $queue,
            payload: $payload,
        );
    }

    /**
     * Publish a payload to the queue.
     */
    protected function pushToQueue(?string $queue, string $payload): void
    {
        $queue = $this->getQueue($queue);

        $message = new AMQPMessage(
            body: $payload,
            properties: [
                'delivery_mode' => 2,
            ],
        );

        $this->channel->basic_publish(
            msg: $message,
            exchange: '',
            routing_key: $queue,
        );
    }

    /**
     * Get the channel instance.
     */
    public function getChannel(): AbstractChannel
    {
        return $this->channel;
    }

    /**
     * Get the connection instance.
     */
    public function getConnection(): AbstractConnection
    {
        return $this->connection;
    }
}
