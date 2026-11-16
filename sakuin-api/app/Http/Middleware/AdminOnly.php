<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminOnly
{
    public function handle(Request $request, Closure $next)
    {
        $u = $request->user();
        if (! $u || ! $u->isAdmin() || $u->status !== 'active') {
            return response()->json(['message' => 'Akses ditolak.'], 403);
        }
        return $next($request);
    }
}