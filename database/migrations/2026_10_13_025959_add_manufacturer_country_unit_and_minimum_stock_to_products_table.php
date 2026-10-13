<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->foreignId('manufacturer_id')
                ->nullable()
                ->constrained('manufacturers')
                ->restrictOnDelete();

            $table->foreignId('country_id')
                ->nullable()
                ->constrained('countries')
                ->restrictOnDelete();

            $table->string('unit', 20)->default('шт.');

            $table->decimal('minimum_stock', 12, 3)->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropConstrainedForeignId('country_id');
            $table->dropConstrainedForeignId('manufacturer_id');

            $table->dropColumn([
                'unit',
                'minimum_stock',
            ]);
        });
    }
};
