<?php
namespace App\Http\Controllers\Admin\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class WebUserController extends Controller
{
    public function index(Request $r)
    {
        $users = User::where('role', 'user')
            ->when($r->search, fn ($q, $v) => $q->where(fn ($q) => $q->where('name', 'like', "%$v%")->orWhere('email', 'like', "%$v%")))
            ->when($r->status, fn ($q, $v) => $q->where('status', $v))
            ->latest()->paginate(15)->withQueryString();
        return view('admin.users.index', compact('users'));
    }

    public function show(User $user)
    {
        abort_if($user->isAdmin(), 404);
        $user->load('budgetSetting')->loadCount(['transactions', 'goals']);
        return view('admin.users.show', compact('user'));
    }

    public function toggle(User $user)
    {
        abort_if($user->isAdmin(), 403);
        $user->update(['status' => $user->status === 'active' ? 'suspended' : 'active']);
        if ($user->status === 'suspended') $user->tokens()->delete();
        return back()->with('ok', 'Status pengguna diubah menjadi '.$user->status.'.');
    }

    public function resetPassword(User $user)
    {
        abort_if($user->isAdmin(), 403);
        $temp = Str::random(10);
        $user->update(['password' => Hash::make($temp)]);
        $user->tokens()->delete();
        return back()->with('ok', "Kata sandi sementara: $temp (catat dan berikan ke pengguna).");
    }

    public function destroy(User $user)
    {
        abort_if($user->isAdmin(), 403);
        $user->delete();
        return redirect()->route('admin.users')->with('ok', 'Pengguna dihapus.');
    }
}