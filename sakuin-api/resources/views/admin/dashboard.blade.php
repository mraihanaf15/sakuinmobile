@extends('admin.layout')
@section('title','Dashboard')
@section('content')
@php $cards=[['Total Pengguna',$d['total_users']],['Pengguna Aktif (30 hari)',$d['active_users']],['Pengguna Baru Bulan Ini',$d['new_users_this_month']],['Total Transaksi',$d['total_transactions']],['Pertanyaan ke AI',$d['ai_questions']]]; @endphp
<div class="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
  @foreach($cards as [$l,$v])
  <div class="bg-white rounded-2xl p-5 border border-brand-100"><div class="text-xs text-mute">{{ $l }}</div><div class="text-3xl font-bold text-brand-700 mt-1">{{ number_format($v,0,',','.') }}</div></div>
  @endforeach
</div>
<div class="grid lg:grid-cols-2 gap-6">
  <div class="bg-white rounded-2xl p-5 border border-brand-100"><h3 class="font-semibold mb-3">Pertumbuhan Pengguna (6 bulan)</h3><canvas id="g"></canvas></div>
  <div class="bg-white rounded-2xl p-5 border border-brand-100"><h3 class="font-semibold mb-3">Pengguna Aktif Harian (7 hari)</h3><canvas id="a"></canvas></div>
</div>
@endsection
@push('scripts')
<script>
const green='#2E9E5B', mint='#E6F4EC';
new Chart(document.getElementById('g'),{type:'line',data:{labels:@json(collect($d['user_growth'])->pluck('month')),datasets:[{label:'Pengguna baru',data:@json(collect($d['user_growth'])->pluck('new_users')),borderColor:green,backgroundColor:mint,fill:true,tension:.35}]}});
new Chart(document.getElementById('a'),{type:'bar',data:{labels:@json($d['daily_active_users']->pluck('date')),datasets:[{label:'Pengguna aktif',data:@json($d['daily_active_users']->pluck('active_users')),backgroundColor:green,borderRadius:8}]}});
</script>
@endpush