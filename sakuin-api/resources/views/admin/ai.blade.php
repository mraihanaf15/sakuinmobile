@extends('admin.layout')
@section('title','Kelola Tanya AI')
@section('content')
<div class="grid lg:grid-cols-3 gap-6">
<form method="POST" action="{{ route('admin.ai.config') }}" class="bg-white rounded-2xl border border-brand-100 p-5 space-y-3 h-fit">@csrf
  <h3 class="font-semibold">Ambang Kesehatan Keuangan</h3>
  <div><label class="text-xs text-mute">Skor minimal "Sehat"</label><input type="number" name="sehat" value="{{ old('sehat',$sehat) }}" class="block w-full rounded-xl border border-brand-100 px-3 py-2 text-sm"></div>
  <div><label class="text-xs text-mute">Skor minimal "Waspada" (di bawahnya Kritis)</label><input type="number" name="waspada" value="{{ old('waspada',$waspada) }}" class="block w-full rounded-xl border border-brand-100 px-3 py-2 text-sm"></div>
  <div><label class="text-xs text-mute">Prompt yang disarankan (1 baris = 1 prompt)</label><textarea name="prompts" rows="5" class="block w-full rounded-xl border border-brand-100 px-3 py-2 text-sm">{{ old('prompts', implode("\n",$prompts)) }}</textarea></div>
  <button class="w-full py-2.5 rounded-xl bg-brand-600 text-white text-sm font-semibold">Simpan</button>
</form>
<div class="lg:col-span-2">
  <form class="mb-3"><select name="status" onchange="this.form.submit()" class="rounded-xl border border-brand-100 bg-white px-4 py-2 text-sm">
    <option value="">Semua status</option>@foreach(['sehat','waspada','kritis','belum_ada_data'] as $s)<option value="{{ $s }}" @selected(request('status')==$s)>{{ ucfirst(str_replace('_',' ',$s)) }}</option>@endforeach</select></form>
  <div class="bg-white rounded-2xl border border-brand-100 overflow-x-auto"><table class="w-full text-sm">
  <thead class="bg-brand-50 text-mute text-left"><tr><th class="p-3">Waktu</th><th>Pengguna</th><th>Pertanyaan</th><th>Status</th><th>Skor</th></tr></thead><tbody>
  @forelse($logs as $l)
  <tr class="border-t border-brand-100"><td class="p-3 whitespace-nowrap text-mute">{{ $l->created_at->format('d M H:i') }}</td><td>{{ $l->user->name ?? '-' }}</td><td class="max-w-xs truncate" title="{{ $l->answer }}">{{ $l->question }}</td>
  <td><span class="px-2 py-1 rounded-full text-xs font-semibold {{ ['sehat'=>'bg-brand-100 text-brand-700','waspada'=>'bg-amber-100 text-amber-700','kritis'=>'bg-red-50 text-red-600'][$l->status] ?? 'bg-gray-100 text-gray-500' }}">{{ $l->status }}</span></td><td>{{ $l->score }}</td></tr>
  @empty<tr><td colspan="5" class="p-8 text-center text-mute">Belum ada pertanyaan.</td></tr>@endforelse
  </tbody></table></div>
  <div class="mt-4">{{ $logs->links() }}</div>
</div></div>
@endsection