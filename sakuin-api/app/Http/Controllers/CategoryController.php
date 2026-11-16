<?php
namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $r)
    {
    return Category::where('is_active', true)
        ->where(fn ($q) => $q->whereNull('user_id')->orWhere('user_id', $r->user()->id))
        ->when($r->type, fn ($q, $v) => $q->where('type', $v))->orderBy('name')->get();
    }

    public function store(Request $r)
    {
        $d = $r->validate(['name' => 'required|string|max:50', 'icon' => 'nullable|string', 'type' => 'required|in:income,expense',
            'bucket' => 'nullable|in:needs,wants,savings']);
        return response()->json(Category::create($d + ['user_id' => $r->user()->id]), 201);
    }
}