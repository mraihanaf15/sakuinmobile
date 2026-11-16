<?php
namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Services\BudgetService;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function __invoke(Request $r, BudgetService $budget)
    {
        $uid = $r->user()->id;
        $months = $r->query('period') === 'yearly' ? 12 : 6;

        $monthly = [];
        for ($i = $months - 1; $i >= 0; $i--) {
            $m = now()->subMonths($i);
            $base = Transaction::where('user_id', $uid)->whereBetween('transaction_date', [$m->copy()->startOfMonth(), $m->copy()->endOfMonth()]);
            $monthly[] = [
                'month' => $m->format('Y-m'),
                'income' => (float) (clone $base)->where('type', 'income')->sum('amount'),
                'expense' => (float) (clone $base)->where('type', 'expense')->sum('amount'),
                'savings' => (float) (clone $base)->where('type', 'expense')->where('bucket', 'savings')->sum('amount'),
            ];
        }
        $cum = 0;
        $savingsGrowth = array_map(function ($row) use (&$cum) { $cum += $row['savings']; return ['month' => $row['month'], 'total' => $cum]; }, $monthly);

        $categories = Transaction::where('transactions.user_id', $uid)->where('type', 'expense')
            ->whereBetween('transaction_date', [now()->startOfMonth(), now()->endOfMonth()])
            ->leftJoin('categories', 'categories.id', '=', 'transactions.category_id')
            ->selectRaw('COALESCE(categories.name, "Lainnya") as name, SUM(amount) as total')
            ->groupBy('name')->orderByDesc('total')->get();

        $weekly = Transaction::where('user_id', $uid)->where('type', 'expense')
            ->whereBetween('transaction_date', [now()->subDays(6)->startOfDay(), now()->endOfDay()])
            ->selectRaw('transaction_date as date, SUM(amount) as total')->groupBy('date')->orderBy('date')->get();

        return [
            'monthly' => $monthly,
            'savings_growth' => $savingsGrowth,
            'allocation' => $budget->summary($r->user())['buckets'],
            'category_breakdown' => $categories,
            'weekly_expense' => $weekly,
        ];
    }
}