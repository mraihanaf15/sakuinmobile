<?php
namespace App\Http\Controllers;

use App\Models\BudgetSetting;
use App\Services\BudgetService;
use Carbon\Carbon;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    public function __construct(private BudgetService $budget) {}

    public function setup(Request $r)
    {
        $data = $r->validate([
            'monthly_income' => 'required|numeric|min:0',
            'needs_pct' => 'sometimes|integer|min:0|max:100',
            'wants_pct' => 'sometimes|integer|min:0|max:100',
            'savings_pct' => 'sometimes|integer|min:0|max:100',
        ]);
        $n = $data['needs_pct'] ?? 50; $w = $data['wants_pct'] ?? 30; $s = $data['savings_pct'] ?? 20;
        if ($n + $w + $s !== 100) {
            return response()->json(['message' => 'Total persentase harus 100%.'], 422);
        }
        $setting = BudgetSetting::updateOrCreate(['user_id' => $r->user()->id],
            ['monthly_income' => $data['monthly_income'], 'needs_pct' => $n, 'wants_pct' => $w, 'savings_pct' => $s]);

        return response()->json(['setting' => $setting, 'split' => [
            'needs' => $data['monthly_income'] * $n / 100,
            'wants' => $data['monthly_income'] * $w / 100,
            'savings' => $data['monthly_income'] * $s / 100,
        ]]);
    }

    public function show(Request $r)
    {
        $month = $r->query('month') ? Carbon::createFromFormat('Y-m', $r->query('month')) : null;
        return $this->budget->summary($r->user(), $month);
    }
}