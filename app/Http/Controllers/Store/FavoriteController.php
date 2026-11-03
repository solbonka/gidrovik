<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Product;
use App\Services\ImageService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class FavoriteController extends Controller
{
    public function getFavorites(): JsonResponse
    {
        $user = auth()->user();
        if (!$user) {
            return response()->json(["product_ids" => []]);
        }
        $productIds = Favorite::where("user_id", $user->id)->pluck("product_id")->toArray();
        return response()->json(["product_ids" => $productIds]);
    }

    public function index(Request $request): Response
    {
        $imageService = app(ImageService::class);

        $favorites = Favorite::where("user_id", $request->user()->id)
            ->with("product")
            ->orderBy("created_at", "desc")
            ->get();

        $products = $favorites->map(function (Favorite $favorite) use ($imageService) {
            $product = $favorite->product;
            return [
                "id" => $product->id,
                "name" => $product->name,
                "slug" => $product->slug,
                "code" => $product->code,
                "article" => $product->article,
                "price" => $product->retail_price ?? "0",
                "image_path" => $product->images->first() ? $imageService->url($product->images->first()->image_path, "thumbnail") : null,
                "stock_status" => $product->stock_status,
                "category" => $product->category?->name,
            ];
        })->values()->toArray();

        return Inertia::render("store/favorites/Index", ["products" => $products]);
    }

    public function store(Request $request)
    {
        $request->validate(["product_id" => "required|exists:products,id"]);
        $favorite = Favorite::firstOrCreate([
            "user_id" => $request->user()->id,
            "product_id" => $request->product_id,
        ], []);

        return redirect()->back()->with("toast", [
            "type" => "success",
            "message" => $favorite->wasRecentlyCreated ? "Товар добавлен в избранное" : "Товар уже в избранном",
        ]);
    }

    public function destroy(Request $request)
    {
        $request->validate(["product_id" => "required|exists:products,id"]);
        Favorite::where("user_id", $request->user()->id)
            ->where("product_id", $request->product_id)
            ->delete();

        return redirect()->back()->with("toast", [
            "type" => "success",
            "message" => "Товар удалён из избранного",
        ]);
    }

    public function toggle(Request $request)
    {
        $request->validate(["product_id" => "required|exists:products,id"]);

        $favorite = Favorite::where("user_id", $request->user()->id)
            ->where("product_id", $request->product_id)
            ->first();

        if ($favorite) {
            $favorite->delete();
            return redirect()->back()->with("toast", [
                "type" => "success",
                "message" => "Товар удалён из избранного",
            ]);
        }

        Favorite::create([
            "user_id" => $request->user()->id,
            "product_id" => $request->product_id,
        ]);

        return redirect()->back()->with("toast", [
            "type" => "success",
            "message" => "Товар добавлен в избранное",
        ]);
    }
}
