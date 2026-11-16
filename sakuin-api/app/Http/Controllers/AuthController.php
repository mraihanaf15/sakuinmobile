<?php
namespace App\Http\Controllers;

use App\Models\BudgetSetting;
use App\Models\Setting;
use App\Models\User;
use App\Services\ActivityLogger;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class AuthController extends Controller
{
    private function payload(User $u, int $status = 200)
    {
        return response()->json([
            'user' => $u->only(['id', 'name', 'email', 'phone', 'role', 'status']),
            'role' => $u->role,
            'token' => $u->createToken('sakuin')->plainTextToken,
        ], $status);
    }

    public function register(Request $r)
    {
        abort_unless(Setting::get('registration_open', true), 403, 'Pendaftaran akun baru sedang ditutup.');

        $data = $r->validate([
            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:users',
            'phone' => 'nullable|string|max:20',
            'password' => 'required|min:8|confirmed',
        ]);
        $user = User::create($data)->refresh();   // role 'user' berasal dari default database
        BudgetSetting::create(['user_id' => $user->id]);

        return $this->payload($user, 201);
    }

    public function login(Request $r)
    {
        $r->validate(['email' => 'required|email', 'password' => 'required']);
        $user = User::where('email', $r->email)->first();

        if (! $user || ! Hash::check($r->password, $user->password)) {
            if ($user?->isAdmin()) {
                ActivityLogger::log($user, 'auth.login_failed', 'Percobaan login admin gagal');
            }
            return response()->json(['message' => 'Email atau kata sandi salah.'], 422);
        }
        if ($user->status === 'suspended') {
            return response()->json(['message' => 'Akun Anda ditangguhkan. Hubungi admin.'], 403);
        }

        $user->update(['last_login_at' => now()]);
        if ($user->isAdmin()) {
            ActivityLogger::log($user, 'auth.login', 'Admin berhasil login');
        }

        return $this->payload($user);
    }

    public function logout(Request $r)
    {
        $user = $r->user();
        if ($user->isAdmin()) {
            ActivityLogger::log($user, 'auth.logout', 'Admin logout');
        }
        $user->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil keluar.']);
    }

    public function me(Request $r) { return $r->user()->load('budgetSetting'); }

    public function updateProfile(Request $r)
    {
        $data = $r->validate(['name' => 'sometimes|string|max:100', 'phone' => 'nullable|string|max:20']);
        $r->user()->update($data);
        return $r->user();
    }

    public function forgotPassword(Request $r)
    {
        $r->validate(['email' => 'required|email|exists:users,email']);
        $otp = (string) random_int(100000, 999999);
        DB::table('password_otps')->where('email', $r->email)->delete();
        DB::table('password_otps')->insert(['email' => $r->email, 'otp' => Hash::make($otp),
            'expires_at' => now()->addMinutes(10), 'created_at' => now(), 'updated_at' => now()]);

        Mail::raw("Kode OTP Sakuin Anda: $otp (berlaku 10 menit)", fn ($m) => $m->to($r->email)->subject('Kode OTP Sakuin'));

        return response()->json(['message' => 'Kode OTP telah dikirim ke email.']);
    }

    public function resetPassword(Request $r)
    {
        $r->validate(['email' => 'required|email', 'otp' => 'required|digits:6', 'password' => 'required|min:8|confirmed']);
        $row = DB::table('password_otps')->where('email', $r->email)->first();

        if (! $row || now()->gt($row->expires_at) || ! Hash::check($r->otp, $row->otp)) {
            return response()->json(['message' => 'OTP tidak valid atau kedaluwarsa.'], 422);
        }
        User::where('email', $r->email)->update(['password' => Hash::make($r->password)]);
        DB::table('password_otps')->where('email', $r->email)->delete();

        return response()->json(['message' => 'Kata sandi berhasil diubah.']);
    }
}