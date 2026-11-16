<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AdminActivityLog extends Model
{
    public const UPDATED_AT = null;

    protected $table = 'admin_activity_logs';
    protected $fillable = ['admin_id', 'action', 'subject_type', 'subject_id', 'description',
        'metadata', 'ip_address', 'user_agent'];
    protected $casts = ['metadata' => 'array', 'created_at' => 'datetime'];

    protected static function booted(): void
    {
        static::updating(fn () => throw new \LogicException('Log aktivitas bersifat read-only.'));
        static::deleting(fn () => throw new \LogicException('Log aktivitas tidak dapat dihapus.'));
    }

    public function admin() { return $this->belongsTo(User::class, 'admin_id'); }
}