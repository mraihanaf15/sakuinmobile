<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminUserController extends Controller
{
    public function index(Request $r)
    {
        return User::where('role', 'user')
            ->when($r->search, fn ($q, $v) => $q->where(fn ($q) => $q->where('name', 'like', "%$v%")->orWhere('email', 'like', "%$v%")))
            ->when($r->status, fn ($q, $v) => $q->where('status', $v))
            ->latest()->paginate(20);
    }

    public function show(User $user)
    {
        return $user->load('budgetSetting')->loadCount('transactions');
    }

    public function toggleStatus(User $user)
    {
        abort_if($user->isAdmin(), 403, 'Tidak dapat mengubah admin.');
        $user->update(['status' => $user->status === 'active' ? 'suspended' : 'active']);
        if ($user->status === 'suspended') $user->tokens()->delete();
        return $user;
    }

    public function resetPassword(User $user)
    {
        abort_if($user->isAdmin(), 403);
        $temp = Str::random(10);
        $user->update(['password' => Hash::make($temp)]);
        $user->tokens()->delete();
        return response()->json(['message' => 'Kata sandi direset.', 'temporary_password' => $temp]);
    }

    public function destroy(User $user)
    {
        abort_if($user->isAdmin(), 403);
        $user->delete();
        return response()->json(['message' => 'Pengguna dihapus.']);
    }
}