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
        Schema::table('products', function (Blueprint $table) {
            $table->decimal('retail_price', 12, 2)
                ->default(0)
                ->after('description');

            $table->boolean('published')
                ->default(false)
                ->after('retail_price');

            $table->string('slug')
                ->nullable()
                ->unique()
                ->after('published');

            $table->string('meta_title')
                ->nullable()
                ->after('slug');

            $table->text('meta_description')
                ->nullable()
                ->after('meta_title');

            $table->index(['published', 'retail_price']);
            $table->index('slug');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropIndex('products_published_retail_price_index');
            $table->dropIndex('products_slug_index');
            $table->dropUnique('products_slug_unique');
            $table->dropColumn(['retail_price', 'published', 'slug', 'meta_title', 'meta_description']);
        });
    }
};
