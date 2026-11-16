<?php
namespace App\Services;

use App\Models\Setting;
use App\Models\Transaction;
use App\Models\User;

class HealthAnalyzer
{
    public function __construct(private BudgetService $budget) {}

    public function analyze(User $user): array
    {
        $s = $this->budget->summary($user);
        $base = $s['base_income'];

        if ($base <= 0) {
            return ['score' => 0, 'status' => 'belum_ada_data', 'actual' => [], 'findings' => ['Belum ada data pemasukan bulan ini.'],
                'tips' => ['Catat pemasukan dan pengeluaranmu terlebih dahulu agar Sakuin bisa menganalisis.'], 'top_categories' => []];
        }

        $actual = [];
        foreach ($s['buckets'] as $k => $b) {
            $actual[$k] = round($b['used'] / $base * 100, 1);
        }

        $score = 100;
        $findings = [];
        $tips = [];

        if ($actual['needs'] > 50) {
            $score -= min(30, ($actual['needs'] - 50) * 1.5);
            $findings[] = "Kebutuhan {$actual['needs']}% dari penghasilan (ideal maks. 50%).";
            $tips[] = 'Tinjau tagihan dan biaya tetap, cari yang bisa dinegosiasikan atau dikurangi.';
        }
        if ($actual['wants'] > 30) {
            $score -= min(30, ($actual['wants'] - 30) * 1.5);
            $findings[] = "Keinginan {$actual['wants']}% dari penghasilan (ideal maks. 30%).";
            $tips[] = 'Kurangi belanja impulsif dan hiburan; tetapkan batas mingguan.';
        }
        if ($actual['savings'] < 20) {
            $score -= min(30, (20 - $actual['savings']) * 1.5);
            $findings[] = "Tabungan & investasi baru {$actual['savings']}% (target min. 20%).";
            $tips[] = 'Sisihkan tabungan di awal bulan (bayar diri sendiri dulu) lewat transfer otomatis.';
        }
        if ($s['expense'] > $s['income'] && $s['income'] > 0) {
            $score -= 15;
            $findings[] = 'Total pengeluaran bulan ini lebih besar dari pemasukan.';
            $tips[] = 'Tunda pengeluaran non-esensial sampai arus kas kembali positif.';
        }

        $score = (int) max(0, min(100, round($score)));
        $th = ['sehat' => (int) Setting::get('threshold_sehat', config('sakuin.thresholds.sehat')),
            'waspada' => (int) Setting::get('threshold_waspada', config('sakuin.thresholds.waspada'))];
        $status = $score >= $th['sehat'] ? 'sehat' : ($score >= $th['waspada'] ? 'waspada' : 'kritis');

        if (! $findings) {
            $findings[] = 'Pengeluaranmu sesuai dengan komposisi 50/30/20. Pertahankan!';
            $tips[] = 'Pertimbangkan menaikkan porsi tabungan atau dana darurat.';
        }

        $top = Transaction::where('transactions.user_id', $user->id)->where('type', 'expense')
            ->whereBetween('transaction_date', [now()->startOfMonth(), now()->endOfMonth()])
            ->leftJoin('categories', 'categories.id', '=', 'transactions.category_id')
            ->selectRaw('COALESCE(categories.name, "Lainnya") as name, SUM(amount) as total')
            ->groupBy('name')->orderByDesc('total')->limit(3)->get();

        return [
            'score' => $score, 'status' => $status, 'actual' => $actual,
            'findings' => $findings, 'tips' => array_slice($tips, 0, 3),
            'top_categories' => $top, 'summary' => $s,
        ];
    }
}