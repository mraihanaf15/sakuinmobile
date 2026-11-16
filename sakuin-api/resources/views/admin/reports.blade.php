@extends('admin.layout')
@section('title','Laporan')
@section('content')
<div class="flex justify-end mb-4"><a href="{{ route('admin.reports.export') }}" class="px-5 py-2.5 rounded-xl bg-brand-600 text-white text-sm font-semibold">Ekspor CSV</a></div>
@php $months=collect($rep['transactions_per_month'])->pluck('month')->unique()->values(); @endphp
<div class="grid lg:grid-cols-3 gap-6">
  <div class="lg:col-span-2 bg-white rounded-2xl p-5 border border-brand-100"><h3 class="font-semibold mb-3">Arus Kas Seluruh Pengguna per Bulan</h3><canvas id="m"></canvas></div>
  <div class="bg-white rounded-2xl p-5 border border-brand-100"><h3 class="font-semibold mb-3">Distribusi Status Kesehatan (AI)</h3><canvas id="s"></canvas></div>
</div>
@endsection
@push('scripts')
<script>
const rows=@json($rep['transactions_per_month']), months=@json($months);
const sum=t=>months.map(m=>Number((rows.find(r=>r.month===m&&r.type===t)||{}).amount||0));
new Chart(document.getElementById('m'),{type:'bar',data:{labels:months,datasets:[{label:'Pemasukan',data:sum('income'),backgroundColor:'#2E9E5B',borderRadius:8},{label:'Pengeluaran',data:sum('expense'),backgroundColor:'#C9E7D6',borderRadius:8}]}});
const st=@json($rep['ai_status_distribution']);
new Chart(document.getElementById('s'),{type:'doughnut',data:{labels:st.map(x=>x.status||'-'),datasets:[{data:st.map(x=>x.total),backgroundColor:['#2E9E5B','#F2B84B','#E5675B','#B8C4BD']}]}});
</script>
@endpush