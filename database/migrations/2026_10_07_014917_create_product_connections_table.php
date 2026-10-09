<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_connections', function (Blueprint $table) {
            $table->id();

            $table->foreignId('product_id')
                ->constrained()
                ->cascadeOnDelete();

            /*
             * 1 — первая сторона
             * 2 — вторая сторона
             * 3 — третья сторона (например, тройник)
             */
            $table->unsignedTinyInteger('position');

            $table->foreignId('standard_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();

            $table->foreignId('diameter_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();

            $table->foreignId('thread_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();

            $table->timestamps();

            $table->unique([
                'product_id',
                'position',
            ]);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_connections');
    }
};
