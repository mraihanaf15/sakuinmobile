<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>@yield('title', 'Dashboard') · Sakuin Admin</title>
<script src="https://cdn.tailwindcss.com"></script>
<script>tailwind.config={theme:{extend:{colors:{brand:{50:'#F7FAF8',100:'#E6F4EC',500:'#2E9E5B',600:'#2E9E5B',700:'#1F7A45'},ink:'#1C2A24',mute:'#8A9A92'},fontFamily:{sans:['Plus Jakarta Sans','Inter','system-ui','sans-serif']}}}}</script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</head>
<body class="bg-brand-50 text-ink font-sans">
@php
  $menu = [
    ['admin.dashboard','Dashboard','M3 12l9-9 9 9M5 10v10h14V10'],
    ['admin.users','Kelola Pengguna','M17 20h5v-2a4 4 0 00-3-3.9M9 20H4v-2a4 4 0 013-3.9M12 12a4 4 0 100-8 4 4 0 000 8z'],
    ['admin.categories','Kelola Kategori','M4 6h16M4 12h16M4 18h7'],
    ['admin.transactions','Monitoring Transaksi','M3 17l6-6 4 4 8-8'],
    ['admin.ai','Kelola Tanya AI','M8 10h8M8 14h5M21 12a9 9 0 11-4-7.5L21 3v5'],
    ['admin.broadcasts','Notifikasi','M15 17h5l-1.4-1.4A2 2 0 0118 14.2V11a6 6 0 10-12 0v3.2a2 2 0 01-.6 1.4L4 17h5m6 0a3 3 0 11-6 0'],
    ['admin.reports','Laporan','M9 17v-6m4 6V7m4 10v-3M5 21h14'],
  ];
@endphp
<div class="flex min-h-screen">
  <aside class="w-64 bg-white border-r border-brand-100 p-5 hidden md:flex flex-col fixed inset-y-0">
    <div class="flex items-center gap-2 mb-8">
      <div class="w-9 h-9 rounded-xl bg-brand-600 flex items-center justify-center">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"><path d="M4 8a3 3 0 013-3h10a3 3 0 013 3v9a3 3 0 01-3 3H7a3 3 0 01-3-3V8z"/><path d="M12 15V9m0 0l-3 3m3-3l3 3"/></svg>
      </div>
      <span class="text-xl font-bold text-brand-700">Sakuin</span>
      <span class="text-[10px] bg-brand-100 text-brand-700 px-2 py-0.5 rounded-full font-semibold">ADMIN</span>
    </div>
    <nav class="space-y-1 flex-1">
      @foreach($menu as [$route,$label,$icon])
        <a href="{{ route($route) }}" class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium {{ request()->routeIs($route.'*') ? 'bg-brand-100 text-brand-700' : 'text-mute hover:bg-brand-50' }}">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="{{ $icon }}"/></svg>{{ $label }}
        </a>
      @endforeach
    </nav>
    <div class="border-t border-brand-100 pt-4">
      <div class="text-sm font-semibold">{{ auth()->user()->name }}</div>
      <div class="text-xs text-mute mb-3">{{ auth()->user()->email }}</div>
      <form method="POST" action="{{ route('admin.logout') }}">@csrf
        <button class="text-sm text-red-500 hover:underline">Keluar</button></form>
    </div>
  </aside>

  <main class="flex-1 md:ml-64 p-6 md:p-8">
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">@yield('title')</h1>
      <span class="text-sm text-mute">{{ now()->translatedFormat('l, d F Y') }}</span>
    </div>
    @if(session('ok'))<div class="mb-4 p-3 rounded-xl bg-brand-100 text-brand-700 text-sm">{{ session('ok') }}</div>@endif
    @if($errors->any())<div class="mb-4 p-3 rounded-xl bg-red-50 text-red-600 text-sm">{{ $errors->first() }}</div>@endif
    @yield('content')
  </main>
</div>
@stack('scripts')
</body>
</html>