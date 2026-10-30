<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class BackfillProductSlugs extends Command
{
    protected $signature = 'products:backfill-slugs';
    protected $description = 'Generate slugs for products that do not have them';

    public function handle(): int
    {
        $updated = DB::table('products')
            ->whereNull('slug')
            ->orWhere('slug', '')
            ->get();

        $count = 0;
        foreach ($updated as $product) {
            DB::table('products')
                ->where('id', $product->id)
                ->update(['slug' => Str::slug($product->name)]);
            $count++;
        }

        $this->info("Slugs generated for {$count} products.");

        return 0;
    }
}
