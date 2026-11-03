<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('custom_tables', function (Blueprint $table) {
            $table->id();

            $table->string('name', 100);
            $table->string('slug', 100)->unique();
            $table->text('description')->nullable();

            // Колонки таблицы: [{ "name": "Название", "key": "name", "type": "string", ... }]
            $table->json('columns')->nullable();

            $table->timestamps();

            $table->index('slug');
        });

        Schema::create('custom_table_entries', function (Blueprint $table) {
            $table->id();

            $table->foreignId('custom_table_id')
                ->constrained('custom_tables')
                ->cascadeOnDelete();

            // Строки данных: { "name": "Значение", ... }
            $table->json('data');

            $table->timestamps();

            $table->index('custom_table_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('custom_table_entries');
        Schema::dropIfExists('custom_tables');
    }
};