<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')
                ->constrained()
                ->cascadeOnDelete();
            $table->foreignId('product_id')
                ->constrained()
                ->restrictOnDelete();
            $table->string('product_name'); // snapshot
            $table->string('product_sku')->nullable(); // snapshot
            $table->decimal('price', 12, 2); // snapshot price
            $table->decimal('quantity', 12, 3);
            $table->decimal('subtotal', 12, 2);
            $table->timestamps();

            $table->index('product_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};
