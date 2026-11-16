<?php
namespace App\Services;

use App\Models\AdminActivityLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class ActivityLogger
{
    private const HIDDEN = ['password', 'password_confirmation', 'current_password', 'token', 'otp'];

    public static function log(?User $admin, string $action, string $description,
        ?Model $subject = null, array $meta = []): AdminActivityLog
    {
        $meta = collect($meta)->except(self::HIDDEN)->all();

        return AdminActivityLog::create([
            'admin_id' => $admin?->id,
            'action' => $action,
            'subject_type' => $subject ? class_basename($subject) : null,
            'subject_id' => $subject?->getKey(),
            'description' => Str::limit($description, 250, ''),
            'metadata' => $meta ?: null,
            'ip_address' => request()->ip(),
            'user_agent' => Str::limit((string) request()->userAgent(), 250, ''),
        ]);
    }
}