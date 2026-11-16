<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = ['user_id', 'category_id', 'type', 'source', 'bucket', 'amount',
        'transaction_date', 'note', 'receipt_path', 'is_recurring'];
    protected $casts = ['transaction_date' => 'date:Y-m-d', 'amount' => 'float', 'is_recurring' => 'boolean'];

    public function category() { return $this->belongsTo(Category::class); }
    public function user() { return $this->belongsTo(User::class); }
}