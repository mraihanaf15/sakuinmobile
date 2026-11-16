<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\UserStatusRequest;
use App\Models\AiLog;
use App\Models\User;
use App\Services\ActivityLogger;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $r)
    {
        $status = $r->query('status');
        return User::query()->where('role', 'user')
            ->when($r->query('search'), function ($q, $v) {
                $v = addcslashes($v, '%_\\');
                $q->where(fn ($q) => $q->where('name', 'like', "%{$v}%")->orWhere('email', 'like', "%{$v}%"));
            })
            ->when(in_array($status, ['active', 'suspended'], true), fn ($q) => $q->where('status', $status))
            ->orderByDesc('id')
            ->select(['id', 'name', 'email', 'phone', 'status', 'created_at', 'last_login_at'])
            ->paginate(15);
    }

    /** Detail aman: profil, status, tanggal, dan statistik hitungan. Tanpa nominal atau isi transaksi. */
    public function show(User $user)
    {
        abort_if($user->isAdmin(), 404);

        return [
            'id' => $user->id, 'name' => $user->name, 'email' => $user->email, 'phone' => $user->phone,
            'status' => $user->status, 'created_at' => $user->created_at, 'last_login_at' => $user->last_login_at,
            'stats' => [
                'transactions_count' => $user->transactions()->count(),
                'goals_count' => $user->goals()->count(),
                'ai_questions_count' => AiLog::where('user_id', $user->id)->count(),
                'last_transaction_at' => $user->transactions()->max('created_at'),
            ],
        ];
    }

    public function updateStatus(UserStatusRequest $r, User $user)
    {
        abort_if($user->id === $r->user()->id, 403, 'Anda tidak dapat mengubah akun sendiri.');
        abort_if($user->isAdmin(), 403, 'Akun admin tidak dapat diubah dari sini.');

        $from = $user->status;
        $user->update(['status' => $r->validated()['status']]);
        if ($user->status === 'suspended') {
            $user->tokens()->delete();   // data transaksi tetap utuh
        }

        ActivityLogger::log($r->user(), 'user.status_changed',
            "Status {$user->email} diubah dari {$from} ke {$user->status}", $user,
            ['from' => $from, 'to' => $user->status, 'reason' => $r->validated()['reason'] ?? null]);

        return $user->only(['id', 'name', 'email', 'status']);
    }
}