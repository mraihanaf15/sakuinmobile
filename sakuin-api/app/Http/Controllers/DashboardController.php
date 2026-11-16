<?php
namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Models\UserNotification;
use App\Services\BudgetService;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function __invoke(Request $r, BudgetService $budget)
    {
        $u = $r->user();
        $totalIncome = (float) Transaction::where('user_id', $u->id)->where('type', 'income')->sum('amount');
        $totalExpense = (float) Transaction::where('user_id', $u->id)->where('type', 'expense')->sum('amount');

        return [
            'total_balance' => $totalIncome - $totalExpense,
            'month' => $budget->summary($u),
            'recent_transactions' => Transaction::with('category')->where('user_id', $u->id)
                ->orderByDesc('transaction_date')->orderByDesc('id')->limit(5)->get(),
            'unread_notifications' => UserNotification::where('user_id', $u->id)->whereNull('read_at')->count(),
        ];
    }
}