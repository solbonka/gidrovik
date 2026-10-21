<?php

/*
 * Тесты всегда должны выполняться на изолированной SQLite базе.
 *
 * Значения из phpunit.xml не достаточно: окружение Docker-контейнера
 * (docker-compose env_file) прокидывает APP_ENV/DB_* в $_SERVER, а
 * Laravel читает переменные окружения именно оттуда. Из-за этого
 * RefreshDatabase мог выполнить migrate:fresh на боевой базе.
 */
$testingEnv = [
    'APP_ENV' => 'testing',
    'APP_MAINTENANCE_DRIVER' => 'file',
    'BCRYPT_ROUNDS' => '4',
    'BROADCAST_CONNECTION' => 'null',
    'CACHE_STORE' => 'array',
    'DB_CONNECTION' => 'sqlite',
    'DB_DATABASE' => ':memory:',
    'DB_URL' => '',
    'MAIL_MAILER' => 'array',
    'QUEUE_CONNECTION' => 'sync',
    'SESSION_DRIVER' => 'array',
    'PULSE_ENABLED' => 'false',
    'TELESCOPE_ENABLED' => 'false',
    'NIGHTWATCH_ENABLED' => 'false',
];

foreach ($testingEnv as $key => $value) {
    putenv("{$key}={$value}");
    $_ENV[$key] = $value;
    $_SERVER[$key] = $value;
}

require __DIR__.'/../vendor/autoload.php';
