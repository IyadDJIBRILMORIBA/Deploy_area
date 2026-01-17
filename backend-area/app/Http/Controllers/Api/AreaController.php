<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Area;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AreaController extends Controller
{
    public function index()
    {
        return response()->json([
            'status' => 'success',
            'data' => Area::where('user_id', Auth::id())->get()
        ]);
    }

    public function store(Request $request)
    {
        // 1. Validation avec les bons noms de champs
        $validated = $request->validate([
            'name' => 'required|string',
            'trigger_service' => 'required|string', // ex: "google"
            'trigger_action'  => 'required|string', // ex: "new_email"
            'trigger_params'  => 'nullable|array',  // JSON en BDD, array ici
            'action_service'  => 'required|string', // ex: "discord"
            'action_reaction' => 'required|string', // ex: "send_message"
            'action_params'   => 'nullable|array',
        ]);

        // 2. Création alignée sur la BDD
        $area = Area::create([
            'user_id' => Auth::id(),
            'name' => $validated['name'],
            
            // Partie TRIGGER (Le "SI")
            'trigger_service' => $validated['trigger_service'],
            'trigger_action'  => $validated['trigger_action'],
            'trigger_params'  => json_encode($validated['trigger_params'] ?? []), // Array vers JSON

            // Partie REACTION (Le "ALORS")
            'action_service'  => $validated['action_service'],
            'action_reaction' => $validated['action_reaction'],
            'action_params'   => json_encode($validated['action_params'] ?? []),

            'is_active' => true
        ]);

        return response()->json(['status' => 'created', 'data' => $area], 201);
    }
}