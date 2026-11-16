<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class SavingGoal extends Model
{
    protected $fillable = ['user_id', 'name', 'target_amount', 'current_amount', 'deadline'];
    protected $casts = ['target_amount' => 'float', 'current_amount' => 'float', 'deadline' => 'date:Y-m-d'];
    protected $appends = ['progress'];

    public function getProgressAttribute(): float
    {
        return $this->target_amount > 0 ? round($this->current_amount / $this->target_amount * 100, 1) : 0;
    }
}