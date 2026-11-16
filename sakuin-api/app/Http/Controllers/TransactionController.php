<?php
namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Transaction;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class TransactionController extends Controller
{
    public function __construct(private NotificationService $notif) {}

    public function index(Request $r)
    {
        $q = Transaction::with('category')->where('user_id', $r->user()->id)
            ->when($r->type, fn ($q, $v) => $q->where('type', $v))
            ->when($r->bucket, fn ($q, $v) => $q->where('bucket', $v))
            ->when($r->category_id, fn ($q, $v) => $q->where('category_id', $v))
            ->when($r->from, fn ($q, $v) => $q->whereDate('transaction_date', '>=', $v))
            ->when($r->to, fn ($q, $v) => $q->whereDate('transaction_date', '<=', $v))
            ->when($r->search, fn ($q, $v) => $q->where('note', 'like', "%$v%"))
            ->orderByDesc('transaction_date')->orderByDesc('id');

        return $q->paginate($r->integer('per_page', 20));
    }

    public function store(Request $r)
    {
        $data = $this->validated($r);
        $data['user_id'] = $r->user()->id;
        $data = $this->fillBucket($data);

        if ($r->hasFile('receipt')) {
            $data['receipt_path'] = $r->file('receipt')->store('receipts', 'public');
        }
        $tx = Transaction::create($data);
        $this->notif->checkBudget($r->user(), $tx);

        return response()->json($tx->load('category'), 201);
    }

    public function show(Request $r, Transaction $transaction)
    {
        $this->authorizeOwner($r, $transaction);
        return $transaction->load('category');
    }

    public function update(Request $r, Transaction $transaction)
    {
        $this->authorizeOwner($r, $transaction);
        $data = $this->fillBucket($this->validated($r, true) + ['type' => $transaction->type]);

        if ($r->hasFile('receipt')) {
            if ($transaction->receipt_path) Storage::disk('public')->delete($transaction->receipt_path);
            $data['receipt_path'] = $r->file('receipt')->store('receipts', 'public');
        }
        $transaction->update($data);
        $this->notif->checkBudget($r->user(), $transaction);

        return $transaction->load('category');
    }

    public function destroy(Request $r, Transaction $transaction)
    {
        $this->authorizeOwner($r, $transaction);
        if ($transaction->receipt_path) Storage::disk('public')->delete($transaction->receipt_path);
        $transaction->delete();
        return response()->json(['message' => 'Transaksi dihapus.']);
    }

    private function validated(Request $r, bool $partial = false): array
    {
        $req = $partial ? 'sometimes' : 'required';
        return $r->validate([
            'type' => $partial ? 'prohibited' : 'required|in:income,expense',
            'amount' => "$req|numeric|min:1",
            'transaction_date' => "$req|date",
            // kategori harus aktif dan milik sendiri atau kategori default
            'category_id' => ['nullable', Rule::exists('categories', 'id')->where(function ($q) use ($r) {
                $q->where('is_active', true)
                  ->where(fn ($q) => $q->whereNull('user_id')->orWhere('user_id', $r->user()->id));
            })],
            'source' => 'nullable|string|max:50',
            'bucket' => 'nullable|in:needs,wants,savings',
            'note' => 'nullable|string',
            'is_recurring' => 'boolean',
            'receipt' => 'nullable|image|max:4096',
        ]);
    }

    private function fillBucket(array $data): array
    {
        unset($data['receipt']);
        if (($data['type'] ?? null) === 'income') { $data['bucket'] = null; return $data; }
        if (empty($data['bucket']) && ! empty($data['category_id'])) {
            $data['bucket'] = Category::find($data['category_id'])?->bucket;
        }
        return $data;
    }

    private function authorizeOwner(Request $r, Transaction $t): void
    {
        abort_if($t->user_id !== $r->user()->id, 403, 'Bukan transaksi Anda.');
    }
}