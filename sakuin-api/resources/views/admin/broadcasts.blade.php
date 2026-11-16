@extends('admin.layout')
@section('title','Kelola Notifikasi')
@section('content')
<div class="grid lg:grid-cols-3 gap-6">
<form method="POST" action="{{ route('admin.broadcasts.send') }}" class="bg-white rounded-2xl border border-brand-100 p-5 space-y-3 h-fit" onsubmit="return confirm('Kirim ke semua pengguna aktif?')">@csrf
  <h3 class="font-semibold">Kirim Pengumuman</h3>
  <div><label class="text-xs text-mute">Judul</label><input name="title" required maxlength="120" class="block w-full rounded-xl border border-brand-100 px-3 py-2 text-sm"></div>
  <div><label class="text-xs text-mute">Isi pesan</label><textarea name="body" rows="5" required class="block w-full rounded-xl border border-brand-100 px-3 py-2 text-sm"></textarea></div>
  <button class="w-full py-2.5 rounded-xl bg-brand-600 text-white text-sm font-semibold">Kirim ke semua pengguna</button>
</form>
<div class="lg:col-span-2 bg-white rounded-2xl border border-brand-100 overflow-x-auto"><table class="w-full text-sm">
<thead class="bg-brand-50 text-mute text-left"><tr><th class="p-3">Judul</th><th>Isi</th><th>Terkirim</th><th>Penerima</th></tr></thead><tbody>
@forelse($history as $h)<tr class="border-t border-brand-100"><td class="p-3 font-medium">{{ $h->title }}</td><td class="max-w-xs truncate">{{ $h->body }}</td><td class="text-mute">{{ \Illuminate\Support\Carbon::parse($h->sent_at)->format('d M Y H:i') }}</td><td>{{ $h->recipients }}</td></tr>
@empty<tr><td colspan="4" class="p-8 text-center text-mute">Belum ada pengumuman.</td></tr>@endforelse
</tbody></table></div></div>
<div class="mt-4">{{ $history->links() }}</div>
@endsection