<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('category_characteristic', function (Blueprint $table) {
            $table->id();

            $table->foreignId('category_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('characteristic_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->boolean('is_required')->default(false);

            $table->unsignedInteger('sort_order')->default(0);

            $table->timestamps();

            $table->unique([
                'category_id',
                'characteristic_id',
            ]);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('category_characteristic');
    }
};
