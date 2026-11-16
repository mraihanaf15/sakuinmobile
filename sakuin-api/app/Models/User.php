<?php
namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = ['name', 'email', 'phone', 'password', 'role', 'status', 'last_login_at'];
    protected $hidden = ['password', 'remember_token'];
    protected $casts = ['password' => 'hashed', 'last_login_at' => 'datetime'];

    public function isAdmin(): bool { return $this->role === 'admin'; }
    public function budgetSetting() { return $this->hasOne(BudgetSetting::class); }
    public function transactions() { return $this->hasMany(Transaction::class); }
    public function goals() { return $this->hasMany(SavingGoal::class); }
    public function userNotifications() { return $this->hasMany(UserNotification::class); }
}