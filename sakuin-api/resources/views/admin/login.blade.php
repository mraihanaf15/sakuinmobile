<!DOCTYPE html>
<html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Masuk Admin · Sakuin</title>
<script src="https://cdn.tailwindcss.com"></script>
<script>tailwind.config={theme:{extend:{colors:{brand:{50:'#F7FAF8',100:'#E6F4EC',600:'#2E9E5B',700:'#1F7A45'},ink:'#1C2A24',mute:'#8A9A92'}}}}</script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet">
</head>
<body class="font-['Plus_Jakarta_Sans',sans-serif] text-ink">
<div class="min-h-screen grid md:grid-cols-2">
  <div class="hidden md:flex flex-col justify-center p-16 text-white bg-gradient-to-br from-brand-600 to-brand-700">
    <div class="w-14 h-14 rounded-2xl bg-white/20 flex items-center justify-center mb-6">
      <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"><path d="M4 8a3 3 0 013-3h10a3 3 0 013 3v9a3 3 0 01-3 3H7a3 3 0 01-3-3V8z"/><path d="M12 15V9m0 0l-3 3m3-3l3 3"/></svg>
    </div>
    <h1 class="text-4xl font-bold mb-3">Sakuin</h1>
    <p class="text-white/80 max-w-sm">Panel admin untuk mengelola pengguna, kategori, notifikasi, dan memantau kesehatan platform keuangan 50/30/20.</p>
  </div>
  <div class="flex items-center justify-center p-8 bg-white">
    <form method="POST" action="{{ route('admin.login.post') }}" class="w-full max-w-sm space-y-4">@csrf
      <h2 class="text-2xl font-bold">Masuk sebagai Admin</h2>
      <p class="text-sm text-mute">Gunakan akun admin Sakuin Anda.</p>
      @if($errors->any())<div class="p-3 rounded-xl bg-red-50 text-red-600 text-sm">{{ $errors->first() }}</div>@endif
      <div><label class="text-sm font-medium">Email</label>
        <input type="email" name="email" value="{{ old('email') }}" required class="mt-1 w-full rounded-xl border border-brand-100 bg-brand-50 px-4 py-3 outline-none focus:ring-2 focus:ring-brand-600"></div>
      <div><label class="text-sm font-medium">Kata sandi</label>
        <input type="password" name="password" required class="mt-1 w-full rounded-xl border border-brand-100 bg-brand-50 px-4 py-3 outline-none focus:ring-2 focus:ring-brand-600"></div>
      <label class="flex items-center gap-2 text-sm text-mute"><input type="checkbox" name="remember"> Ingat saya</label>
      <button class="w-full py-3 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-semibold">Masuk</button>
    </form>
  </div>
</div></body></html>