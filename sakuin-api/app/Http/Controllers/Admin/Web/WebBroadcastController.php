<?php
namespace App\Http\Controllers\Admin\Web;

use App\Http\Controllers\Admin\AdminBroadcastController;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class WebBroadcastController extends Controller
{
    public function index()
    {
        return view('admin.broadcasts', ['history' => app(AdminBroadcastController::class)->history()]);
    }

    public function send(Request $r)
    {
        $res = app(AdminBroadcastController::class)->send($r);
        return back()->with('ok', $res->getData()->message);
    }
}