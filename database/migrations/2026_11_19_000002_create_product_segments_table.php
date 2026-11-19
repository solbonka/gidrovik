<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_segments', function (Blueprint $table) {
            $table->id();

            $table->foreignId('product_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('location_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('parent_segment_id')
                ->nullable()
                ->constrained('product_segments')
                ->nullOnDelete();

            $table->decimal('length_mm', 12, 3);

            $table->string('status', 16)->default('available');

            $table->foreignId('stock_movement_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();

            $table->timestamps();

            $table->index(['product_id', 'status']);
            $table->index(['location_id', 'status']);
            $table->index(['product_id', 'location_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_segments');
    }
};
