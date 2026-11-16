<?php
use App\Http\Controllers\Api\Admin\{ActivityLogController as AdminActivityLogController,
    CategoryController as AdminCategoryController, DashboardController as AdminDashboardController,
    SettingController as AdminSettingController, TipController as AdminTipController,
    UserController as AdminUserController};
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\{AiController, AuthController, BudgetController, CategoryController, DashboardController,
    GoalController, NotificationController, ReportController, TipController, TransactionController};
use Illuminate\Support\Facades\Route;

// Publik
Route::get('health', HealthController::class);
Route::post('register', [AuthController::class, 'register'])->middleware('throttle:10,1');
Route::post('login', [AuthController::class, 'login'])->middleware('throttle:login');
Route::post('forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:5,1');
Route::post('reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:10,1');

Route::middleware('auth:sanctum')->group(function () {
    // Pengguna
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('me', [AuthController::class, 'me']);
    Route::put('me', [AuthController::class, 'updateProfile']);

    Route::post('budget/setup', [BudgetController::class, 'setup']);
    Route::get('budget', [BudgetController::class, 'show']);
    Route::get('dashboard', DashboardController::class);
    Route::get('reports', ReportController::class);

    Route::apiResource('transactions', TransactionController::class);
    Route::get('categories', [CategoryController::class, 'index']);
    Route::post('categories', [CategoryController::class, 'store']);
    Route::get('tips', [TipController::class, 'index']);

    Route::apiResource('goals', GoalController::class)->except('show');
    Route::post('goals/{goal}/deposit', [GoalController::class, 'deposit']);

    Route::get('notifications', [NotificationController::class, 'index']);
    Route::post('notifications/read-all', [NotificationController::class, 'readAll']);
    Route::post('notifications/{notification}/read', [NotificationController::class, 'read']);

    Route::get('ai/prompts', [AiController::class, 'prompts']);
    Route::post('ai/ask', [AiController::class, 'ask'])->middleware('throttle:20,1');

    // Admin (role admin + status aktif, diperiksa ulang oleh backend)
    Route::prefix('admin')->middleware(['admin', 'throttle:60,1'])->group(function () {
        Route::get('dashboard', AdminDashboardController::class);

        Route::get('users', [AdminUserController::class, 'index']);
        Route::get('users/{user}', [AdminUserController::class, 'show']);
        Route::patch('users/{user}/status', [AdminUserController::class, 'updateStatus']);

        Route::apiResource('categories', AdminCategoryController::class)->except('show');

        Route::apiResource('tips', AdminTipController::class)->except('show');
        Route::patch('tips/{tip}/publish', [AdminTipController::class, 'publish']);

        Route::get('activity-logs', [AdminActivityLogController::class, 'index']);

        Route::get('settings', [AdminSettingController::class, 'index']);
        Route::put('settings', [AdminSettingController::class, 'update']);
    });
});