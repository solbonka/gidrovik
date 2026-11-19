<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            // Длина одного куска в мм для товаров stock_mode = length.
            // NULL — обычный товар или мерный товар, продаваемый метрами.
            $table->decimal('length_mm', 12, 3)->nullable()->after('quantity');
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->decimal('length_mm', 12, 3)->nullable()->after('quantity');
        });
    }

    public function down(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropColumn('length_mm');
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->dropColumn('length_mm');
        });
    }
};
