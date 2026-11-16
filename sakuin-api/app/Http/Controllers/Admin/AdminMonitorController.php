<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AiLog;
use App\Models\Setting;
use App\Models\Transaction;
use Illuminate\Http\Request;

class AdminMonitorController extends Controller
{
    public function transactions(Request $r)
    {
        $anomalyLimit = (float) $r->query('anomaly_amount', 50000000);
        return [
            'total_income' => (float) Transaction::where('type', 'income')->sum('amount'),
            'total_expense' => (float) Transaction::where('type', 'expense')->sum('amount'),
            'by_bucket' => Transaction::where('type', 'expense')->selectRaw('bucket, SUM(amount) as total')->groupBy('bucket')->get(),
            'flagged' => Transaction::with('user:id,name,email')->where('amount', '>=', $anomalyLimit)->latest()->limit(50)->get(),
        ];
    }

    public function aiLogs(Request $r)
    {
        return AiLog::with('user:id,name,email')->when($r->status, fn ($q, $v) => $q->where('status', $v))->latest()->paginate(20);
    }

    public function aiConfig()
    {
        return [
            'thresholds' => ['sehat' => Setting::get('threshold_sehat', config('sakuin.thresholds.sehat')),
                'waspada' => Setting::get('threshold_waspada', config('sakuin.thresholds.waspada'))],
            'suggested_prompts' => Setting::get('suggested_prompts', config('sakuin.suggested_prompts')),
        ];
    }

    public function reports()
    {
        return [
            'transactions_per_month' => Transaction::selectRaw("DATE_FORMAT(transaction_date,'%Y-%m') as month, type, COUNT(*) as total, SUM(amount) as amount")
                ->groupBy('month', 'type')->orderBy('month')->get(),
            'ai_status_distribution' => AiLog::selectRaw('status, COUNT(*) as total')->groupBy('status')->get(),
        ];
    }
}