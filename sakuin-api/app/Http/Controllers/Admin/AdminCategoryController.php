<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class AdminCategoryController extends Controller
{
    public function index() { return Category::whereNull('user_id')->orderBy('name')->get(); }

    public function store(Request $r)
    {
        return response()->json(Category::create($this->rules($r) + ['is_default' => true]), 201);
    }

    public function update(Request $r, Category $category)
    {
        $category->update($this->rules($r));
        return $category;
    }

    public function destroy(Category $category)
    {
        $category->delete();
        return response()->json(['message' => 'Kategori dihapus.']);
    }

    private function rules(Request $r): array
    {
        return $r->validate(['name' => 'required|string|max:50', 'icon' => 'nullable|string',
            'type' => 'required|in:income,expense', 'bucket' => 'nullable|in:needs,wants,savings']);
    }
}