<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class Tip extends Model
{
    protected $fillable = ['title', 'body', 'category', 'is_published', 'published_at', 'created_by'];
    protected $casts = ['is_published' => 'boolean', 'published_at' => 'datetime'];

    public function scopePublished(Builder $q): Builder
    {
        return $q->where('is_published', true);
    }
}