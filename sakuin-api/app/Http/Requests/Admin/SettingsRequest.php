<?php
namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class SettingsRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() === true; }

    protected function prepareForValidation(): void
    {
        if (is_array($this->input('suggested_prompts'))) {
            $clean = collect($this->input('suggested_prompts'))
                ->map(fn ($p) => is_string($p) ? trim(strip_tags($p)) : '')
                ->filter()->values()->all();
            $this->merge(['suggested_prompts' => $clean]);
        }
        if (is_string($this->input('app_name'))) {
            $this->merge(['app_name' => trim(strip_tags($this->input('app_name')))]);
        }
    }

    public function rules(): array
    {
        return [
            'app_name' => ['sometimes', 'string', 'max:60'],
            'support_email' => ['sometimes', 'nullable', 'email', 'max:120'],
            'registration_open' => ['sometimes', 'boolean'],
            'threshold_sehat' => ['sometimes', 'integer', 'between:1,100'],
            'threshold_waspada' => ['sometimes', 'integer', 'between:1,99'],
            'suggested_prompts' => ['sometimes', 'array', 'max:10'],
            'suggested_prompts.*' => ['string', 'max:120'],
        ];
    }
}