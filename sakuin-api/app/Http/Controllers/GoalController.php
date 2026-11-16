<?php
namespace App\Http\Controllers;

use App\Models\SavingGoal;
use App\Services\NotificationService;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function index(Request $r) { return SavingGoal::where('user_id', $r->user()->id)->latest()->get(); }

    public function store(Request $r)
    {
        $d = $r->validate(['name' => 'required|string|max:100', 'target_amount' => 'required|numeric|min:1', 'deadline' => 'nullable|date']);
        return response()->json(SavingGoal::create($d + ['user_id' => $r->user()->id]), 201);
    }

    public function update(Request $r, SavingGoal $goal)
    {
        abort_if($goal->user_id !== $r->user()->id, 403);
        $goal->update($r->validate(['name' => 'sometimes|string', 'target_amount' => 'sometimes|numeric|min:1', 'deadline' => 'nullable|date']));
        return $goal;
    }

    public function deposit(Request $r, SavingGoal $goal, NotificationService $notif)
    {
        abort_if($goal->user_id !== $r->user()->id, 403);
        $r->validate(['amount' => 'required|numeric|min:1']);
        $wasDone = $goal->current_amount >= $goal->target_amount;
        $goal->increment('current_amount', $r->amount);
        $goal->refresh();

        if (! $wasDone && $goal->current_amount >= $goal->target_amount) {
            $notif->push($r->user(), 'goal_achieved', 'Target tercapai! 🎉', "Target \"{$goal->name}\" sudah tercapai.");
        }
        return $goal;
    }

    public function destroy(Request $r, SavingGoal $goal)
    {
        abort_if($goal->user_id !== $r->user()->id, 403);
        $goal->delete();
        return response()->json(['message' => 'Target dihapus.']);
    }
}