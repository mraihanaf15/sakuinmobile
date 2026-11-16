@extends('admin.layout')
@section('title','Kelola Pengguna')
@section('content')
<form class="flex flex-wrap gap-3 mb-4">
  <input name="search" value="{{ request('search') }}" placeholder="Cari nama / email" class="rounded-xl border border-brand-100 bg-white px-4 py-2.5 text-sm w-72">
  <select name="status" class="rounded-xl border border-brand-100 bg-white px-4 py-2.5 text-sm">
    <option value="">Semua status</option><option value="active" @selected(request('status')=='active')>Aktif</option><option value="suspended" @selected(request('status')=='suspended')>Ditangguhkan</option></select>
  <button class="px-5 rounded-xl bg-brand-600 text-white text-sm font-semibold">Filter</button>
</form>
<div class="bg-white rounded-2xl border border-brand-100 overflow-x-auto">
<table class="w-full text-sm"><thead class="bg-brand-50 text-mute text-left"><tr><th class="p-3">Nama</th><th>Email</th><th>Status</th><th>Terakhir login</th><th>Aksi</th></tr></thead><tbody>
@forelse($users as $u)
<tr class="border-t border-brand-100"><td class="p-3 font-medium">{{ $u->name }}</td><td>{{ $u->email }}</td>
<td><span class="px-2 py-1 rounded-full text-xs font-semibold {{ $u->status=='active' ? 'bg-brand-100 text-brand-700' : 'bg-red-50 text-red-600' }}">{{ $u->status=='active' ? 'Aktif' : 'Ditangguhkan' }}</span></td>
<td class="text-mute">{{ $u->last_login_at?->diffForHumans() ?? '-' }}</td>
<td class="space-x-3"><a href="{{ route('admin.users.show',$u) }}" class="text-brand-700 hover:underline">Detail</a>
<form method="POST" action="{{ route('admin.users.toggle',$u) }}" class="inline">@csrf<button class="text-amber-600 hover:underline">{{ $u->status=='active' ? 'Suspend' : 'Aktifkan' }}</button></form></td></tr>
@empty<tr><td colspan="5" class="p-8 text-center text-mute">Belum ada pengguna.</td></tr>@endforelse
</tbody></table></div>
<div class="mt-4">{{ $users->links() }}</div>
@endsection