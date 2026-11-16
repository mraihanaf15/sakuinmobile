@extends('admin.layout')
@section('title','Detail Pengguna')
@section('content')
<div class="bg-white rounded-2xl border border-brand-100 p-6 max-w-2xl">
  <div class="text-xl font-bold">{{ $user->name }}</div><div class="text-mute text-sm mb-4">{{ $user->email }} · {{ $user->phone ?? '-' }}</div>
  <dl class="grid grid-cols-2 gap-4 text-sm mb-6">
    <div><dt class="text-mute">Status</dt><dd class="font-semibold">{{ $user->status }}</dd></div>
    <div><dt class="text-mute">Bergabung</dt><dd class="font-semibold">{{ $user->created_at->format('d M Y') }}</dd></div>
    <div><dt class="text-mute">Total transaksi</dt><dd class="font-semibold">{{ $user->transactions_count }}</dd></div>
    <div><dt class="text-mute">Target tabungan</dt><dd class="font-semibold">{{ $user->goals_count }}</dd></div>
    <div><dt class="text-mute">Penghasilan bulanan</dt><dd class="font-semibold">Rp {{ number_format($user->budgetSetting->monthly_income ?? 0,0,',','.') }}</dd></div>
    <div><dt class="text-mute">Persentase</dt><dd class="font-semibold">{{ $user->budgetSetting->needs_pct ?? 50 }}/{{ $user->budgetSetting->wants_pct ?? 30 }}/{{ $user->budgetSetting->savings_pct ?? 20 }}</dd></div>
  </dl>
  <div class="flex flex-wrap gap-3">
    <form method="POST" action="{{ route('admin.users.toggle',$user) }}">@csrf<button class="px-4 py-2 rounded-xl bg-amber-100 text-amber-700 text-sm font-semibold">{{ $user->status=='active' ? 'Suspend' : 'Aktifkan' }}</button></form>
    <form method="POST" action="{{ route('admin.users.reset',$user) }}" onsubmit="return confirm('Reset kata sandi pengguna ini?')">@csrf<button class="px-4 py-2 rounded-xl bg-brand-100 text-brand-700 text-sm font-semibold">Reset kata sandi</button></form>
    <form method="POST" action="{{ route('admin.users.destroy',$user) }}" onsubmit="return confirm('Hapus pengguna beserta seluruh datanya?')">@csrf @method('DELETE')<button class="px-4 py-2 rounded-xl bg-red-50 text-red-600 text-sm font-semibold">Hapus</button></form>
    <a href="{{ route('admin.users') }}" class="px-4 py-2 text-sm text-mute">← Kembali</a>
  </div>
</div>
@endsection