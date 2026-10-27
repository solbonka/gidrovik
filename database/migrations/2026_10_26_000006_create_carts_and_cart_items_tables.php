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
        Schema::create('carts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();
            $table->string('session_id')
                ->nullable()
                ->index();
            $table->timestamps();

            $table->index(['user_id', 'created_at']);
        });

        Schema::create('cart_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cart_id')
                ->constrained()
                ->cascadeOnDelete();
            $table->foreignId('product_id')
                ->constrained()
                ->restrictOnDelete();
            $table->decimal('quantity', 12, 3);
            $table->timestamps();

            $table->unique(['cart_id', 'product_id']);
            $table->index('product_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cart_items');
        Schema::dropIfExists('carts');
    }
};
