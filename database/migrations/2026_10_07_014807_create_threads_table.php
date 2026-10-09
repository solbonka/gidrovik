<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('threads', function (Blueprint $table) {
            $table->id();

            /*
             * metric
             * bsp
             * npt
             */
            $table->string('system', 20);

            $table->string('designation');

            $table->string('name');

            $table->boolean('is_active')->default(true);

            $table->timestamps();

            $table->unique([
                'system',
                'designation',
            ]);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('threads');
    }
};
