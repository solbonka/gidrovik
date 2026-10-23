<?php

namespace App\Queue\Connectors;

use App\Queue\AmqpQueue;
use Illuminate\Contracts\Queue\Queue as QueueContract;
use Illuminate\Queue\Connectors\ConnectorInterface;
use PhpAmqpLib\Connection\AMQPStreamConnection;

class AmqpConnector implements ConnectorInterface
{
    /**
     * Establish a queue connection.
     */
    public function connect(array $config): QueueContract
    {
        $connection = new AMQPStreamConnection(
            host: $config['host'] ?? 'localhost',
            port: $config['port'] ?? 5672,
            user: $config['user'] ?? 'guest',
            password: $config['password'] ?? 'guest',
            vhost: $config['vhost'] ?? '/',
        );

        $channel = $connection->channel();

        $channel->queue_declare(
            queue: $config['queue'] ?? 'default',
            passive: false,
            durable: true,
            exclusive: false,
            auto_delete: false,
        );

        return new AmqpQueue(
            connection: $connection,
            channel: $channel,
            queue: $config['queue'] ?? 'default',
            retryAfter: (int) ($config['retry_after'] ?? 60),
            connectionName: 'amqp',
        );
    }
}
