<?php
namespace App\Http\Controllers\Admin\Web;

use App\Http\Controllers\Controller;
use App\Models\AiLog;
use App\Models\Setting;
use Illuminate\Http\Request;

class WebAiController extends Controller
{
    public function index(Request $r)
    {
        return view('admin.ai', [
            'logs' => AiLog::with('user:id,name,email')->when($r->status, fn ($q, $v) => $q->where('status', $v))->latest()->paginate(15)->withQueryString(),
            'sehat' => Setting::get('threshold_sehat', config('sakuin.thresholds.sehat')),
            'waspada' => Setting::get('threshold_waspada', config('sakuin.thresholds.waspada')),
            'prompts' => Setting::get('suggested_prompts', config('sakuin.suggested_prompts')),
        ]);
    }

    public function saveConfig(Request $r)
    {
        $d = $r->validate(['sehat' => 'required|integer|min:1|max:100', 'waspada' => 'required|integer|min:1|max:99|lt:sehat',
            'prompts' => 'required|string']);
        Setting::put('threshold_sehat', (int) $d['sehat']);
        Setting::put('threshold_waspada', (int) $d['waspada']);
        Setting::put('suggested_prompts', array_values(array_filter(array_map('trim', preg_split('/\R/', $d['prompts'])))));
        return back()->with('ok', 'Konfigurasi Tanya AI disimpan.');
    }
}