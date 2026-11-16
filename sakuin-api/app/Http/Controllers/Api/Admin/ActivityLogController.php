<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use Illuminate\Http\Request;

class ActivityLogController extends Controller
{
    public function index(Request $r)
    {
        $r->validate(['from' => 'nullable|date', 'to' => 'nullable|date', 'admin_id' => 'nullable|integer']);

        return AdminActivityLog::with('admin:id,name')
            ->when($r->query('action'), fn ($q, $v) => $q->where('action', 'like', addcslashes($v, '%_\\').'%'))
            ->when($r->query('admin_id'), fn ($q, $v) => $q->where('admin_id', $v))
            ->when($r->query('from'), fn ($q, $v) => $q->whereDate('created_at', '>=', $v))
            ->when($r->query('to'), fn ($q, $v) => $q->whereDate('created_at', '<=', $v))
            ->orderByDesc('id')->paginate(20)
            ->through(fn ($l) => [
                'id' => $l->id, 'action' => $l->action, 'description' => $l->description,
                'subject_type' => $l->subject_type, 'subject_id' => $l->subject_id,
                'metadata' => $l->metadata, 'admin' => $l->admin?->name,
                'ip_address' => $l->ip_address, 'created_at' => $l->created_at?->toIso8601String(),
            ]);
    }
}