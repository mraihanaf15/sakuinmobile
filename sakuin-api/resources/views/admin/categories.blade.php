@extends('admin.layout')
@section('title','Kelola Kategori')
@section('content')
@php $bk=['needs'=>'Kebutuhan','wants'=>'Keinginan','savings'=>'Tabungan']; @endphp
<form method="POST" action="{{ route('admin.categories.store') }}" class="bg-white rounded-2xl border border-brand-100 p-4 mb-5 flex flex-wrap gap-3 items-end">@csrf
  <div><label class="text-xs text-mute">Nama</label><input name="name" required class="block rounded-xl border border-brand-100 px-3 py-2 text-sm"></div>
  <div><label class="text-xs text-mute">Ikon</label><input name="icon" placeholder="restaurant" class="block rounded-xl border border-brand-100 px-3 py-2 text-sm"></div>
  <div><label class="text-xs text-mute">Tipe</label><select name="type" class="block rounded-xl border border-brand-100 px-3 py-2 text-sm"><option value="expense">Pengeluaran</option><option value="income">Pemasukan</option></select></div>
  <div><label class="text-xs text-mute">Bucket</label><select name="bucket" class="block rounded-xl border border-brand-100 px-3 py-2 text-sm"><option value="">-</option>@foreach($bk as $k=>$l)<option value="{{ $k }}">{{ $l }}</option>@endforeach</select></div>
  <button class="px-5 py-2 rounded-xl bg-brand-600 text-white text-sm font-semibold">Tambah</button>
</form>
<div class="bg-white rounded-2xl border border-brand-100 overflow-x-auto"><table class="w-full text-sm">
<thead class="bg-brand-50 text-mute text-left"><tr><th class="p-3">Nama</th><th>Ikon</th><th>Tipe</th><th>Bucket</th><th></th></tr></thead><tbody>
@foreach($categories as $c)
<tr class="border-t border-brand-100">
<form method="POST" action="{{ route('admin.categories.update',$c) }}">@csrf @method('PUT')
<td class="p-2"><input name="name" value="{{ $c->name }}" class="rounded-lg border border-brand-100 px-2 py-1.5 w-40"></td>
<td><input name="icon" value="{{ $c->icon }}" class="rounded-lg border border-brand-100 px-2 py-1.5 w-32"></td>
<td><select name="type" class="rounded-lg border border-brand-100 px-2 py-1.5"><option value="expense" @selected($c->type=='expense')>Pengeluaran</option><option value="income" @selected($c->type=='income')>Pemasukan</option></select></td>
<td><select name="bucket" class="rounded-lg border border-brand-100 px-2 py-1.5"><option value="">-</option>@foreach($bk as $k=>$l)<option value="{{ $k }}" @selected($c->bucket==$k)>{{ $l }}</option>@endforeach</select></td>
<td class="space-x-3 whitespace-nowrap"><button class="text-brand-700 hover:underline">Simpan</button>
</form>
<form method="POST" action="{{ route('admin.categories.destroy',$c) }}" class="inline" onsubmit="return confirm('Hapus kategori ini?')">@csrf @method('DELETE')<button class="text-red-500 hover:underline">Hapus</button></form></td></tr>
@endforeach
</tbody></table></div>
@endsection