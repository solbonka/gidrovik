<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('segment_movements', function (Blueprint $table) {
            $table->id();

            $table->foreignId('product_segment_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('product_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->string('type', 24);

            $table->foreignId('from_location_id')
                ->nullable()
                ->constrained('locations')
                ->nullOnDelete();

            $table->foreignId('to_location_id')
                ->nullable()
                ->constrained('locations')
                ->nullOnDelete();

            $table->decimal('length_mm', 12, 3);

            $table->foreignId('stock_movement_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();

            $table->text('comment')->nullable();

            $table->foreignId('user_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();

            $table->timestamps();

            $table->index(['product_id', 'created_at']);
            $table->index(['product_segment_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('segment_movements');
    }
};
