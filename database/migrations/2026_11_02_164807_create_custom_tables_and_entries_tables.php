<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create("custom_tables", function (Blueprint $table) {
            $table->id();
            $table->string("name");
            $table->string("slug")->unique();
            $table->text("description")->nullable();
            $table->json("columns")->nullable();
            $table->timestamps();
        });

        Schema::create("custom_table_entries", function (Blueprint $table) {
            $table->id();
            $table->foreignId("custom_table_id")->constrained()->cascadeOnDelete();
            $table->json("data");
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists("custom_table_entries");
        Schema::dropIfExists("custom_tables");
    }
};
