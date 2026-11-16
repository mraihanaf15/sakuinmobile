<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CategoryRequest;
use App\Models\Category;
use App\Services\ActivityLogger;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $r)
    {
        return Category::whereNull('user_id')->withCount('transactions as used_count')
            ->when($r->query('search'), fn ($q, $v) => $q->where('name', 'like', '%'.addcslashes($v, '%_\\').'%'))
            ->when(in_array($r->query('type'), ['income', 'expense'], true), fn ($q) => $q->where('type', $r->query('type')))
            ->when($r->query('status') === 'active', fn ($q) => $q->where('is_active', true))
            ->when($r->query('status') === 'inactive', fn ($q) => $q->where('is_active', false))
            ->orderBy('type')->orderBy('name')->get();
    }

    public function store(CategoryRequest $r)
    {
        $data = $r->validated();
        if ($data['type'] === 'income') $data['bucket'] = null;

        $c = Category::create($data + ['user_id' => null, 'is_default' => true])->refresh();
        ActivityLogger::log($r->user(), 'category.created', "Kategori {$c->name} ditambahkan", $c, ['type' => $c->type]);

        return response()->json($c, 201);
    }

    public function update(CategoryRequest $r, Category $category)
    {
        abort_if($category->user_id !== null, 404);
        $data = $r->validated();
        if ($data['type'] === 'income') $data['bucket'] = null;

        $category->update($data);
        ActivityLogger::log($r->user(), 'category.updated', "Kategori {$category->name} diperbarui", $category,
            ['changes' => collect($category->getChanges())->except('updated_at')->all()]);

        return $category->refresh();
    }

    public function destroy(Request $r, Category $category)
    {
        abort_if($category->user_id !== null, 404);

        $used = $category->transactions()->count();
        if ($used > 0) {
            return response()->json([
                'message' => "Kategori dipakai pada {$used} transaksi dan tidak dapat dihapus. Nonaktifkan kategori ini sebagai gantinya.",
            ], 409);
        }

        $name = $category->name;
        ActivityLogger::log($r->user(), 'category.deleted', "Kategori {$name} dihapus", $category);
        $category->delete();

        return response()->json(['message' => 'Kategori dihapus.']);
    }
}