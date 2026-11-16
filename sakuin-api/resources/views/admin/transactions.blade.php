@extends('admin.layout')
@section('title','Monitoring Transaksi')
@section('content')
@php $bl=['needs'=>'Kebutuhan','wants'=>'Keinginan','savings'=>'Tabungan']; @endphp
<div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
  <div class="bg-white rounded-2xl p-5 border border-brand-100"><div class="text-xs text-mute">Total pemasukan</div><div class="text-xl font-bold text-brand-700">Rp {{ number_format($m['total_income'],0,',','.') }}</div></div>
  <div class="bg-white rounded-2xl p-5 border border-brand-100"><div class="text-xs text-mute">Total pengeluaran</div><div class="text-xl font-bold text-red-500">Rp {{ number_format($m['total_expense'],0,',','.') }}</div></div>
  @foreach($m['by_bucket']->whereNotNull('bucket')->take(2) as $b)
  <div class="bg-white rounded-2xl p-5 border border-brand-100"><div class="text-xs text-mute">Pengeluaran {{ $bl[$b->bucket] ?? $b->bucket }}</div><div class="text-xl font-bold">Rp {{ number_format($b->total,0,',','.') }}</div></div>
  @endforeach
</div>
<form class="flex items-end gap-3 mb-3"><div><label class="text-xs text-mute">Batas anomali (Rp)</label><input name="anomaly_amount" value="{{ $limit }}" class="block rounded-xl border border-brand-100 bg-white px-3 py-2 text-sm"></div><button class="px-5 py-2 rounded-xl bg-brand-600 text-white text-sm font-semibold">Terapkan</button></form>
<div class="bg-white rounded-2xl border border-brand-100 overflow-x-auto"><table class="w-full text-sm">
<thead class="bg-brand-50 text-mute text-left"><tr><th class="p-3">Tanggal</th><th>Pengguna</th><th>Tipe</th><th>Jumlah</th><th>Catatan</th></tr></thead><tbody>
@forelse($m['flagged'] as $t)
<tr class="border-t border-brand-100"><td class="p-3">{{ $t->transaction_date->format('d M Y') }}</td><td>{{ $t->user->name ?? '-' }}</td><td>{{ $t->type=='income'?'Pemasukan':'Pengeluaran' }}</td><td class="font-semibold">Rp {{ number_format($t->amount,0,',','.') }}</td><td class="text-mute">{{ $t->note }}</td></tr>
@empty<tr><td colspan="5" class="p-8 text-center text-mute">Tidak ada transaksi di atas batas anomali.</td></tr>@endforelse
</tbody></table></div>
@endsection