<?php
use App\Http\Controllers\Admin\Web\{WebAiController, WebAuthController, WebBroadcastController, WebCategoryController,
    WebDashboardController, WebMonitorController, WebUserController};
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/admin');

Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('login', [WebAuthController::class, 'showLogin'])->name('login');
    Route::post('login', [WebAuthController::class, 'login'])->name('login.post')->middleware('throttle:10,1');

    Route::middleware('admin.web')->group(function () {
        Route::post('logout', [WebAuthController::class, 'logout'])->name('logout');
        Route::get('/', WebDashboardController::class)->name('dashboard');

        Route::get('users', [WebUserController::class, 'index'])->name('users');
        Route::get('users/{user}', [WebUserController::class, 'show'])->name('users.show');
        Route::post('users/{user}/toggle', [WebUserController::class, 'toggle'])->name('users.toggle');
        Route::post('users/{user}/reset-password', [WebUserController::class, 'resetPassword'])->name('users.reset');
        Route::delete('users/{user}', [WebUserController::class, 'destroy'])->name('users.destroy');

        Route::get('categories', [WebCategoryController::class, 'index'])->name('categories');
        Route::post('categories', [WebCategoryController::class, 'store'])->name('categories.store');
        Route::put('categories/{category}', [WebCategoryController::class, 'update'])->name('categories.update');
        Route::delete('categories/{category}', [WebCategoryController::class, 'destroy'])->name('categories.destroy');

        Route::get('transactions', [WebMonitorController::class, 'transactions'])->name('transactions');
        Route::get('reports', [WebMonitorController::class, 'reports'])->name('reports');
        Route::get('reports/export', [WebMonitorController::class, 'export'])->name('reports.export');

        Route::get('ai', [WebAiController::class, 'index'])->name('ai');
        Route::post('ai/config', [WebAiController::class, 'saveConfig'])->name('ai.config');

        Route::get('broadcasts', [WebBroadcastController::class, 'index'])->name('broadcasts');
        Route::post('broadcasts', [WebBroadcastController::class, 'send'])->name('broadcasts.send');
    });
});