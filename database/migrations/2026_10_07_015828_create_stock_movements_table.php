<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stock_movements', function (Blueprint $table) {
            $table->id();

            $table->foreignId('product_id')
                ->constrained()
                ->restrictOnDelete();

            /*
             * NULL → поступление
             * location → списание
             * location → location → перемещение
             */
            $table->foreignId('from_location_id')
                ->nullable()
                ->constrained('locations')
                ->restrictOnDelete();

            $table->foreignId('to_location_id')
                ->nullable()
                ->constrained('locations')
                ->restrictOnDelete();

            $table->unsignedInteger('quantity');

            /*
             * receipt
             * transfer
             * write_off
             * return
             * inventory
             */
            $table->string('type', 30);

            $table->text('comment')->nullable();

            $table->foreignId('user_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();

            $table->timestamps();

            $table->index([
                'product_id',
                'created_at',
            ]);

            $table->index([
                'from_location_id',
                'created_at',
            ]);

            $table->index([
                'to_location_id',
                'created_at',
            ]);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_movements');
    }
};
