<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\SettingsRequest;
use App\Models\Setting;
use App\Services\ActivityLogger;
use Illuminate\Validation\ValidationException;

class SettingController extends Controller
{
    private function defaults(): array
    {
        return [
            'app_name' => 'Sakuin',
            'support_email' => null,
            'registration_open' => true,
            'threshold_sehat' => config('sakuin.thresholds.sehat'),
            'threshold_waspada' => config('sakuin.thresholds.waspada'),
            'suggested_prompts' => config('sakuin.suggested_prompts'),
        ];
    }

    private function current(): array
    {
        $out = [];
        foreach ($this->defaults() as $k => $d) $out[$k] = Setting::get($k, $d);
        return $out;
    }

    public function index() { return $this->current(); }

    public function update(SettingsRequest $r)
    {
        $data = $r->validated();
        $cur = $this->current();

        $sehat = $data['threshold_sehat'] ?? $cur['threshold_sehat'];
        $waspada = $data['threshold_waspada'] ?? $cur['threshold_waspada'];
        if ($waspada >= $sehat) {
            throw ValidationException::withMessages(
                ['threshold_waspada' => 'Ambang Waspada harus lebih kecil dari ambang Sehat.']);
        }

        $changes = [];
        foreach ($data as $k => $v) {
            if (json_encode($cur[$k]) !== json_encode($v)) {
                $changes[$k] = ['from' => $cur[$k], 'to' => $v];
                Setting::put($k, $v);
            }
        }
        if ($changes) {
            ActivityLogger::log($r->user(), 'settings.updated', 'Pengaturan sistem diperbarui', null, ['changes' => $changes]);
        }

        return $this->current();
    }
}