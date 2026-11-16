<?php
namespace App\Services;

use App\Models\BudgetSetting;
use App\Models\Transaction;
use App\Models\User;
use Carbon\Carbon;

class BudgetService
{
    public const BUCKETS = ['needs' => 'Kebutuhan', 'wants' => 'Keinginan', 'savings' => 'Tabungan & Investasi'];

    public function summary(User $user, ?Carbon $month = null): array
    {
        $month ??= now();
        $start = $month->copy()->startOfMonth();
        $end   = $month->copy()->endOfMonth();

        $setting = BudgetSetting::firstOrCreate(['user_id' => $user->id]);

        $q = Transaction::where('user_id', $user->id)->whereBetween('transaction_date', [$start, $end]);
        $income = (float) (clone $q)->where('type', 'income')->sum('amount');
        $expense = (float) (clone $q)->where('type', 'expense')->sum('amount');

        // Dasar hitung: pemasukan aktual bulan ini, fallback ke penghasilan bulanan di setup.
        $base = $income > 0 ? $income : (float) $setting->monthly_income;

        $pcts = ['needs' => $setting->needs_pct, 'wants' => $setting->wants_pct, 'savings' => $setting->savings_pct];
        $buckets = [];
        foreach ($pcts as $key => $pct) {
            $limit = round($base * $pct / 100, 2);
            $used = (float) (clone $q)->where('type', 'expense')->where('bucket', $key)->sum('amount');
            $percent = $limit > 0 ? round($used / $limit * 100, 1) : ($used > 0 ? 100 : 0);
            $buckets[$key] = [
                'label' => self::BUCKETS[$key],
                'percentage' => $pct,
                'limit' => $limit,
                'used' => $used,
                'remaining' => round($limit - $used, 2),
                'used_percent' => $percent,
                'status' => $this->status($percent),
            ];
        }

        return [
            'month' => $start->format('Y-m'),
            'base_income' => $base,
            'income' => $income,
            'expense' => $expense,
            'balance_month' => $income - $expense,
            'buckets' => $buckets,
        ];
    }

    public function status(float $percent): string
    {
        if ($percent > 100) return 'melebihi_batas';
        if ($percent >= config('sakuin.warning_percent', 80)) return 'hampir_habis';
        return 'aman';
    }
}