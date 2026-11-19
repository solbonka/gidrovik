<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('stock_mode', 16)
                ->default('quantity')
                ->after('unit');

            $table->boolean('allow_cutting')
                ->default(false)
                ->after('stock_mode');

            $table->decimal('cut_width_mm', 10, 3)
                ->nullable()
                ->after('allow_cutting');

            $table->decimal('min_remainder_mm', 12, 3)
                ->nullable()
                ->after('cut_width_mm');

            $table->decimal('min_sale_length_mm', 12, 3)
                ->nullable()
                ->after('min_remainder_mm');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn([
                'stock_mode',
                'allow_cutting',
                'cut_width_mm',
                'min_remainder_mm',
                'min_sale_length_mm',
            ]);
        });
    }
};
