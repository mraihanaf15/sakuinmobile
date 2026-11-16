<?php
namespace App\Services;

use App\Models\Transaction;
use App\Models\User;
use App\Models\UserNotification;

class NotificationService
{
    public function __construct(private BudgetService $budget) {}

    public function push(User $user, string $type, string $title, string $body): UserNotification
    {
        // TODO: kirim juga push notification (FCM) untuk Flutter di sini.
        return UserNotification::create(['user_id' => $user->id, 'type' => $type, 'title' => $title, 'body' => $body]);
    }

    public function checkBudget(User $user, Transaction $tx): void
    {
        if ($tx->type !== 'expense' || ! $tx->bucket) return;

        $b = $this->budget->summary($user, $tx->transaction_date)['buckets'][$tx->bucket];
        $label = $b['label'];
        $month = $tx->transaction_date->format('Y-m');

        if ($b['status'] === 'melebihi_batas') {
            $this->pushOnce($user, 'budget_exceeded', "Anggaran $label melebihi batas",
                "Pengeluaran $label sudah {$b['used_percent']}% dari batas bulan ini.", $month);
        } elseif ($b['status'] === 'hampir_habis') {
            $this->pushOnce($user, 'budget_warning', "Anggaran $label hampir habis",
                "Pengeluaran $label sudah {$b['used_percent']}% dari batas bulan ini.", $month);
        }
    }

    private function pushOnce(User $user, string $type, string $title, string $body, string $month): void
    {
        $exists = UserNotification::where('user_id', $user->id)->where('type', $type)->where('title', $title)
            ->where('created_at', '>=', $month.'-01')->exists();
        if (! $exists) $this->push($user, $type, $title, $body);
    }
}