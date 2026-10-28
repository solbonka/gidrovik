<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->renameColumn('sku', 'code');
        });

        Schema::table('products', function (Blueprint $table) {
            $table->string('article')->nullable()->after('code');
        });

        Schema::table('order_items', function (Blueprint $table) {
            if (Schema::hasColumn('order_items', 'product_sku')) {
                $table->renameColumn('product_sku', 'product_code');
            }
        });
    }

    public function down(): void
    {
        Schema::table('order_items', function (Blueprint $table) {
            if (Schema::hasColumn('order_items', 'product_code')) {
                $table->renameColumn('product_code', 'product_sku');
            }
        });

        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn('article');
        });

        Schema::table('products', function (Blueprint $table) {
            $table->renameColumn('code', 'sku');
        });
    }
};
