<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class HealthController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $databaseOk = true;

        try {
            DB::connection()->getPdo();
        } catch (\Throwable $e) {
            report($e);
            $databaseOk = false;
        }

        return response()->json([
            'success' => $databaseOk,
            'message' => $databaseOk
                ? 'SAKUIN API berjalan normal.'
                : 'Server aktif, tetapi database tidak dapat dijangkau.',
            'data' => [
                'app'         => config('app.name'),
                'database'    => $databaseOk,
                'server_time' => now()->toIso8601String(),
            ],
        ], $databaseOk ? 200 : 503);
    }
}