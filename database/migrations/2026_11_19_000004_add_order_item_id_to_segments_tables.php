<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_segments', function (Blueprint $table) {
            $table->foreignId('order_item_id')
                ->nullable()
                ->after('stock_movement_id')
                ->constrained('order_items')
                ->nullOnDelete();

            $table->index('order_item_id');
        });

        Schema::table('segment_movements', function (Blueprint $table) {
            $table->foreignId('order_item_id')
                ->nullable()
                ->after('stock_movement_id')
                ->constrained('order_items')
                ->nullOnDelete();

            $table->index('order_item_id');
        });
    }

    public function down(): void
    {
        Schema::table('product_segments', function (Blueprint $table) {
            $table->dropConstrainedForeignId('order_item_id');
        });

        Schema::table('segment_movements', function (Blueprint $table) {
            $table->dropConstrainedForeignId('order_item_id');
        });
    }
};
