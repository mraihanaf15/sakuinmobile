<?php
namespace App\Http\Controllers;

use App\Models\UserNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $r)
    {
        return UserNotification::where('user_id', $r->user()->id)
            ->when($r->type, fn ($q, $v) => $q->where('type', $v))
            ->when($r->boolean('unread'), fn ($q) => $q->whereNull('read_at'))
            ->latest()->paginate(20);
    }

    public function read(Request $r, UserNotification $notification)
    {
        abort_if($notification->user_id !== $r->user()->id, 403);
        $notification->update(['read_at' => now()]);
        return $notification;
    }

    public function readAll(Request $r)
    {
        UserNotification::where('user_id', $r->user()->id)->whereNull('read_at')->update(['read_at' => now()]);
        return response()->json(['message' => 'Semua ditandai terbaca.']);
    }
}