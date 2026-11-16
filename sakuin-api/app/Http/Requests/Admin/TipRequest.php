<?php
namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class TipRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() === true; }

    protected function prepareForValidation(): void
    {
        foreach (['title', 'body'] as $k) {
            if (is_string($this->input($k))) {
                $this->merge([$k => trim(strip_tags($this->input($k)))]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:120'],
            'body' => ['required', 'string', 'max:2000'],
            'category' => ['required', 'in:umum,anggaran,menabung,pengeluaran,darurat,gaya-hidup'],
            'is_published' => ['sometimes', 'boolean'],
        ];
    }
}