<?php
namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CategoryRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() === true; }

    protected function prepareForValidation(): void
    {
        if (is_string($this->input('name'))) {
            $this->merge(['name' => trim(strip_tags($this->input('name')))]);
        }
    }

    public function rules(): array
    {
        $category = $this->route('category');
        return [
            'name' => ['required', 'string', 'max:50',
                Rule::unique('categories', 'name')
                    ->where(fn ($q) => $q->whereNull('user_id')->where('type', $this->input('type')))
                    ->ignore($category?->id)],
            'icon' => ['nullable', 'string', 'max:50', 'regex:/^[A-Za-z0-9_]+$/'],
            'type' => ['required', 'in:income,expense'],
            'bucket' => ['required_if:type,expense', 'nullable', 'in:needs,wants,savings'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}