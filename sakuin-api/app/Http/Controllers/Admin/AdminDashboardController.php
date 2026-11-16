<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AiLog;
use App\Models\Transaction;
use App\Models\User;

class AdminDashboardController extends Controller
{
    public function __invoke()
    {
        $growth = [];
        for ($i = 5; $i >= 0; $i--) {
            $m = now()->subMonths($i);
            $growth[] = ['month' => $m->format('Y-m'),
                'new_users' => User::where('role', 'user')->whereBetween('created_at', [$m->copy()->startOfMonth(), $m->copy()->endOfMonth()])->count()];
        }
        $dau = Transaction::whereBetween('transaction_date', [now()->subDays(6)->startOfDay(), now()->endOfDay()])
            ->selectRaw('transaction_date as date, COUNT(DISTINCT user_id) as active_users')->groupBy('date')->orderBy('date')->get();

        return [
            'total_users' => User::where('role', 'user')->count(),
            'active_users' => User::where('role', 'user')->where('last_login_at', '>=', now()->subDays(30))->count(),
            'new_users_this_month' => User::where('role', 'user')->where('created_at', '>=', now()->startOfMonth())->count(),
            'total_transactions' => Transaction::count(),
            'ai_questions' => AiLog::count(),
            'user_growth' => $growth,
            'daily_active_users' => $dau,
        ];
    }
}