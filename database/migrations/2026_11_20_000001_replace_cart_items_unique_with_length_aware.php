<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropUnique(['cart_id', 'product_id']);
        });

        // Один товар может встречаться в корзине несколько раз с разной
        // длиной куска (length_mm). Для строк без длины сохраняем
        // уникальность (cart_id, product_id) через частичный индекс.
        DB::statement('CREATE UNIQUE INDEX cart_items_cart_product_null_length_unique ON cart_items (cart_id, product_id) WHERE length_mm IS NULL');
        DB::statement('CREATE UNIQUE INDEX cart_items_cart_product_length_unique ON cart_items (cart_id, product_id, length_mm) WHERE length_mm IS NOT NULL');
    }

    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS cart_items_cart_product_null_length_unique');
        DB::statement('DROP INDEX IF EXISTS cart_items_cart_product_length_unique');

        Schema::table('cart_items', function (Blueprint $table) {
            $table->unique(['cart_id', 'product_id']);
        });
    }
};
