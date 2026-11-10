<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->boolean('is_featured')
                ->default(false)
                ->after('published');
            $table->unsignedInteger('featured_position')
                ->nullable()
                ->after('is_featured');

            $table->index(['is_featured', 'featured_position']);
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropIndex(['is_featured', 'featured_position']);
            $table->dropColumn(['is_featured', 'featured_position']);
        });
    }
};
