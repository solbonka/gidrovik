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
        Schema::create('characteristic_values', function (Blueprint $table) {
            $table->id();
            $table->foreignId('characteristic_id')->constrained()->onDelete('cascade');
            $table->string('value');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->unique(['characteristic_id', 'value']);
            $table->index('characteristic_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('characteristic_values');
    }
};
