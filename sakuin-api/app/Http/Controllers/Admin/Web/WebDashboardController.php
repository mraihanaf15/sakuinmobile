<?php
namespace App\Http\Controllers\Admin\Web;

use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Controller;

class WebDashboardController extends Controller
{
    public function __invoke()
    {
        return view('admin.dashboard', ['d' => app(AdminDashboardController::class)()]);
    }
}