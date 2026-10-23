<?php

namespace App\Queue\Jobs;

use App\Queue\AmqpQueue;
use Illuminate\Container\Container;
use Illuminate\Contracts\Queue\Job as JobContract;
use Illuminate\Queue\Jobs\Job;
use PhpAmqpLib\Message\AMQPMessage;

class AmqpJob extends Job implements JobContract
{
    /**
     * The AMQP message instance.
     *
     * @var AMQPMessage
     */
    protected $message;

    /**
     * The AMQP queue instance.
     *
     * @var AmqpQueue
     */
    protected $amqpQueue;

    /**
     * The number of times the job has been attempted.
     *
     * @var int
     */
    protected $attempts;

    /**
     * Create a new job instance.
     */
    public function __construct(
        Container $container,
        AmqpQueue $queue,
        AMQPMessage $message,
        string $queueName,
        array $payload
    ) {
        $this->message = $message;
        $this->queue = $queue;
        $this->container = $container;
        $this->connectionName = $queue->getConnectionName();
        $this->queue = $queueName;
        $this->attempts = (int) ($message->has('x-attempts') ? $message->get('x-attempts') : 1);
    }

    /**
     * Get the job identifier.
     */
    public function getJobId(): string
    {
        return (string) $this->message->getDeliveryTag();
    }

    /**
     * Get the raw body string for the job.
     */
    public function getRawBody(): string
    {
        return $this->message->getBody();
    }

    /**
     * Release the job back into the queue after (n) seconds.
     */
    public function release($delay = 0): void
    {
        parent::release($delay);

        $payload = $this->payload();
        $payload['attempts'] = ($payload['attempts'] ?? 0) + 1;

        $message = new AMQPMessage(
            body: json_encode($payload, JSON_UNESCAPED_UNICODE),
            properties: [
                'delivery_mode' => 2,
                'headers' => array_merge(
                    $this->message->get_properties()['headers'] ?? [],
                    [
                        'x-attempts' => $payload['attempts'],
                    ]
                ),
            ],
        );

        if ($delay > 0) {
            $message->set('x-delay', (int) $delay * 1000);
        }

        $this->amqpQueue->getChannel()->basic_publish(
            msg: $message,
            exchange: '',
            routing_key: $this->queue,
        );

        $this->message->ack();
    }

    /**
     * Delete the job from the queue.
     */
    public function delete(): void
    {
        parent::delete();

        $this->message->ack();
    }

    /**
     * Get the number of times the job has been attempted.
     */
    public function attempts(): int
    {
        return $this->attempts;
    }

    /**
     * Mark the job as "failed".
     */
    public function markAsFailed(): void
    {
        parent::markAsFailed();

        $this->message->nack(false);
    }

    /**
     * Get the underlying AMQP message.
     */
    public function getMessage(): AMQPMessage
    {
        return $this->message;
    }
}
