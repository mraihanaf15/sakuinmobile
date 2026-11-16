<?php
namespace App\Http\Controllers;

use App\Models\Tip;

class TipController extends Controller
{
    public function index()
    {
        return Tip::published()->orderByDesc('published_at')
            ->select(['id', 'title', 'body', 'category', 'published_at'])->paginate(10);
    }
}