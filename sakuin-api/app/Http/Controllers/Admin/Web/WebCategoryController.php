<?php
namespace App\Http\Controllers\Admin\Web;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class WebCategoryController extends Controller
{
    public function index()
    {
        return view('admin.categories', ['categories' => Category::whereNull('user_id')->orderBy('type')->orderBy('name')->get()]);
    }

    public function store(Request $r)
    {
        Category::create($this->data($r) + ['is_default' => true]);
        return back()->with('ok', 'Kategori ditambahkan.');
    }

    public function update(Request $r, Category $category)
    {
        $category->update($this->data($r));
        return back()->with('ok', 'Kategori diperbarui.');
    }

    public function destroy(Category $category)
    {
        $category->delete();
        return back()->with('ok', 'Kategori dihapus.');
    }

    private function data(Request $r): array
    {
        $d = $r->validate(['name' => 'required|string|max:50', 'icon' => 'nullable|string|max:50',
            'type' => 'required|in:income,expense', 'bucket' => 'nullable|in:needs,wants,savings']);
        if ($d['type'] === 'income') $d['bucket'] = null;
        return $d;
    }
}