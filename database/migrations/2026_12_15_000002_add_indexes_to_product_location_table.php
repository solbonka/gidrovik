<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_location', function (Blueprint $table) {
            $table->index('quantity');
            $table->index(['product_id', 'quantity']);
            $table->index(['location_id', 'quantity']);
        });
    }

    public function down(): void
    {
        Schema::table('product_location', function (Blueprint $table) {
            $table->dropIndex(['quantity']);
            $table->dropIndex(['product_id', 'quantity']);
            $table->dropIndex(['location_id', 'quantity']);
        });
    }
};
