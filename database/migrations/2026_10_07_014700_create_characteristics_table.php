<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('characteristics', function (Blueprint $table) {
            $table->id();

            $table->string('name');
            $table->string('slug')->unique();

            /*
             * Тип значения характеристики:
             *
             * string      — обычный текст
             * integer     — целое число
             * decimal     — число с дробной частью
             * boolean     — да/нет
             * select      — выбор из списка
             */
            $table->string('type', 30);

            $table->string('unit')->nullable();

            $table->boolean('is_active')->default(true);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('characteristics');
    }
};
