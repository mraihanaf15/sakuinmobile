<?php
namespace App\Http\Controllers\Admin\Web;

use App\Http\Controllers\Admin\AdminMonitorController;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class WebMonitorController extends Controller
{
    public function transactions(Request $r)
    {
        $m = app(AdminMonitorController::class)->transactions($r);
        return view('admin.transactions', ['m' => $m, 'limit' => (float) $r->query('anomaly_amount', 50000000)]);
    }

    public function reports()
    {
        return view('admin.reports', ['rep' => app(AdminMonitorController::class)->reports()]);
    }

    public function export()
    {
        $rows = app(AdminMonitorController::class)->reports()['transactions_per_month'];
        return response()->streamDownload(function () use ($rows) {
            $out = fopen('php://output', 'w');
            fputcsv($out, ['Bulan', 'Tipe', 'Jumlah Transaksi', 'Total (Rp)']);
            foreach ($rows as $r) fputcsv($out, [$r->month, $r->type, $r->total, $r->amount]);
            fclose($out);
        }, 'laporan-sakuin-'.now()->format('Ymd').'.csv', ['Content-Type' => 'text/csv']);
    }
}