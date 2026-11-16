<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use App\Models\AiLog;
use App\Models\Category;
use App\Models\Tip;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $members = fn () => User::where('role', 'user');

        $growth = collect(range(5, 0))->map(function ($i) use ($members) {
            $m = now()->subMonthsNoOverflow($i);
            return [
                'month' => $m->format('Y-m'),
                'new_users' => $members()->whereBetween('created_at',
                    [$m->copy()->startOfMonth(), $m->copy()->endOfMonth()])->count(),
            ];
        })->values();

        $rows = Transaction::selectRaw('transaction_date as d, COUNT(*) as c, COUNT(DISTINCT user_id) as u')
            ->where('transaction_date', '>=', now()->subDays(6)->toDateString())
            ->groupBy('transaction_date')->get()
            ->keyBy(fn ($r) => \Carbon\Carbon::parse($r->d)->toDateString());

        $daily = collect(range(6, 0))->map(function ($i) use ($rows) {
            $d = now()->subDays($i)->toDateString();
            return ['date' => $d,
                'transactions' => (int) ($rows->get($d)?->c ?? 0),
                'active_users' => (int) ($rows->get($d)?->u ?? 0)];
        })->values();

        $dbOk = true;
        try { DB::connection()->getPdo(); } catch (\Throwable) { $dbOk = false; }

        return response()->json([
            'users' => [
                'total' => $members()->count(),
                'active' => $members()->where('status', 'active')->count(),
                'suspended' => $members()->where('status', 'suspended')->count(),
                'new_this_month' => $members()->where('created_at', '>=', now()->startOfMonth())->count(),
                'active_30_days' => $members()->where('last_login_at', '>=', now()->subDays(30))->count(),
            ],
            'usage' => [
                'total_transactions' => Transaction::count(),
                'transactions_last_7_days' => $daily->sum('transactions'),
                'ai_questions' => AiLog::count(),
                'published_tips' => Tip::published()->count(),
                'active_categories' => Category::whereNull('user_id')->where('is_active', true)->count(),
            ],
            'growth' => $growth,
            'daily' => $daily,
            'recent_activity' => AdminActivityLog::with('admin:id,name')->latest('id')->limit(8)->get()
                ->map(fn ($l) => [
                    'id' => $l->id, 'action' => $l->action, 'description' => $l->description,
                    'admin' => $l->admin?->name, 'created_at' => $l->created_at?->toIso8601String(),
                ])->values(),
            'system' => [
                'database' => $dbOk,
                'laravel' => app()->version(),
                'php' => PHP_VERSION,
                'server_time' => now()->toIso8601String(),
                'debug_enabled' => (bool) config('app.debug'),
            ],
        ]);
    }
}