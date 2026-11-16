<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class BudgetSetting extends Model
{
    protected $fillable = ['user_id', 'monthly_income', 'needs_pct', 'wants_pct', 'savings_pct'];
}