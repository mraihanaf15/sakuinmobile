<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\TipRequest;
use App\Models\Tip;
use App\Services\ActivityLogger;
use Illuminate\Http\Request;

class TipController extends Controller
{
    public function index(Request $r)
    {
        return Tip::query()
            ->when($r->query('search'), fn ($q, $v) => $q->where('title', 'like', '%'.addcslashes($v, '%_\\').'%'))
            ->when($r->query('category'), fn ($q, $v) => $q->where('category', $v))
            ->when($r->query('status') === 'published', fn ($q) => $q->where('is_published', true))
            ->when($r->query('status') === 'draft', fn ($q) => $q->where('is_published', false))
            ->orderByDesc('id')->paginate(15);
    }

    public function store(TipRequest $r)
    {
        $data = $r->validated() + ['created_by' => $r->user()->id];
        if (! empty($data['is_published'])) $data['published_at'] = now();

        $tip = Tip::create($data)->refresh();
        ActivityLogger::log($r->user(), 'tip.created', "Tips \"{$tip->title}\" dibuat", $tip,
            ['published' => $tip->is_published]);

        return response()->json($tip, 201);
    }

    public function update(TipRequest $r, Tip $tip)
    {
        $data = $r->validated();
        if (! empty($data['is_published']) && ! $tip->published_at) $data['published_at'] = now();

        $tip->update($data);
        ActivityLogger::log($r->user(), 'tip.updated', "Tips \"{$tip->title}\" diperbarui", $tip);

        return $tip->refresh();
    }

    public function publish(Request $r, Tip $tip)
    {
        $d = $r->validate(['is_published' => ['required', 'boolean']]);
        $tip->update([
            'is_published' => $d['is_published'],
            'published_at' => ($d['is_published'] && ! $tip->published_at) ? now() : $tip->published_at,
        ]);
        ActivityLogger::log($r->user(), $tip->is_published ? 'tip.published' : 'tip.unpublished',
            "Tips \"{$tip->title}\" ".($tip->is_published ? 'dipublikasikan' : 'ditarik dari publikasi'), $tip);

        return $tip->refresh();
    }

    public function destroy(Request $r, Tip $tip)
    {
        ActivityLogger::log($r->user(), 'tip.deleted', "Tips \"{$tip->title}\" dihapus", $tip);
        $tip->delete();

        return response()->json(['message' => 'Tips dihapus.']);
    }
}