<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserNotification;
use Illuminate\Http\Request;

class AdminBroadcastController extends Controller
{
    public function send(Request $r)
    {
        $d = $r->validate(['title' => 'required|string|max:120', 'body' => 'required|string']);
        $count = 0;
        User::where('role', 'user')->where('status', 'active')->chunkById(500, function ($users) use ($d, &$count) {
            $rows = $users->map(fn ($u) => ['user_id' => $u->id, 'type' => 'broadcast', 'title' => $d['title'],
                'body' => $d['body'], 'created_at' => now(), 'updated_at' => now()])->all();
            UserNotification::insert($rows);
            $count += count($rows);
        });
        // TODO: kirim FCM push ke perangkat Flutter.
        return response()->json(['message' => "Pengumuman terkirim ke $count pengguna."]);
    }

    public function history()
    {
        return UserNotification::where('type', 'broadcast')->selectRaw('title, body, MIN(created_at) as sent_at, COUNT(*) as recipients')
            ->groupBy('title', 'body')->orderByDesc('sent_at')->paginate(20);
    }
}