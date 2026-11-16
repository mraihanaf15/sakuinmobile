<?php
namespace App\Http\Controllers;

use App\Models\AiLog;
use App\Models\Setting;
use App\Services\HealthAnalyzer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AiController extends Controller
{
    public function prompts() { return Setting::get('suggested_prompts', config('sakuin.suggested_prompts')); }

    public function ask(Request $r, HealthAnalyzer $analyzer)
    {
        $r->validate(['question' => 'required|string|max:500']);
        $analysis = $analyzer->analyze($r->user());
        $answer = $this->narrate($r->question, $analysis) ?? $this->fallbackAnswer($analysis);

        AiLog::create(['user_id' => $r->user()->id, 'question' => $r->question, 'answer' => $answer,
            'status' => $analysis['status'], 'score' => $analysis['score']]);

        return [
            'answer' => $answer,
            'health' => ['status' => $analysis['status'], 'score' => $analysis['score'],
                'actual' => $analysis['actual'], 'findings' => $analysis['findings'], 'tips' => $analysis['tips'],
                'top_categories' => $analysis['top_categories']],
        ];
    }

    // Jawaban natural dari Claude (aktif jika ANTHROPIC_API_KEY diisi di .env)
    private function narrate(string $question, array $a): ?string
    {
        $key = config('sakuin.ai.key');
        if (! $key) return null;

        try {
            $res = Http::withHeaders(['x-api-key' => $key, 'anthropic-version' => '2023-06-01'])->timeout(30)
                ->post('https://api.anthropic.com/v1/messages', [
                    'model' => config('sakuin.ai.model'),
                    'max_tokens' => 600,
                    'system' => 'Kamu adalah asisten keuangan aplikasi Sakuin. Jawab singkat, ramah, dalam Bahasa Indonesia, '
                        .'berdasarkan data dan aturan 50/30/20 yang diberikan. Jangan memberi saran investasi spesifik.',
                    'messages' => [['role' => 'user', 'content' => "Pertanyaan: $question\n\nData analisis (JSON): "
                        .json_encode($a, JSON_UNESCAPED_UNICODE)]],
                ]);
            return $res->successful() ? ($res->json('content.0.text') ?: null) : null;
        } catch (\Throwable) {
            return null;
        }
    }

    private function fallbackAnswer(array $a): string
    {
        $label = ['sehat' => 'SEHAT ✅', 'waspada' => 'WASPADA ⚠️', 'kritis' => 'KRITIS 🚨', 'belum_ada_data' => 'BELUM ADA DATA'][$a['status']];
        return "Kondisi keuanganmu bulan ini: $label (skor {$a['score']}/100).\n"
            .implode("\n", array_map(fn ($f) => "• $f", $a['findings']))."\n\nSaran:\n"
            .implode("\n", array_map(fn ($t) => "• $t", $a['tips']));
    }
}