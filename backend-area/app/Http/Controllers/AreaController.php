<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Area;
use Illuminate\Support\Facades\Validator;

class AreaController extends Controller
{
    /**
     * List AREAs for the authenticated user
     *
     * @group AREAs
     * @authenticated
     *
     * @response 200 {
     *  "areas": []
     * }
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $areas = Area::where('user_id', $user->id)->get();

        return response()->json(['areas' => $areas], 200);
    }

    /**
     * Create a new AREA
     *
     * @group AREAs
     * @authenticated
     *
     * @bodyParam name string required Name of the AREA. Example: "Sync Calendar to Discord"
     * @bodyParam trigger_service string required Trigger service id. Example: "google"
     * @bodyParam trigger_action string required Trigger action id. Example: "new_event"
     * @bodyParam trigger_params object Optional trigger parameters
     * @bodyParam action_service string required Action service id. Example: "discord"
     * @bodyParam action_reaction string required Action reaction id. Example: "send_message"
     * @bodyParam action_params object Optional action parameters
     *
     * @response 201 {
     *  "message": "AREA created successfully",
     *  "area": { }
     * }
     */
    public function store(Request $request)
    {
        $user = $request->user();

        // Log pour debug
        \Log::info('[AreaController] Création AREA - Données reçues:', $request->all());

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'trigger_service' => 'required|string',
            'trigger_action' => 'required|string',
            'action_service' => 'required|string',
            'action_reaction' => 'required|string',
            'trigger_params' => 'nullable|array',
            'action_params' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            \Log::error('[AreaController] Validation échouée:', $validator->errors()->toArray());
            return response()->json(['message' => 'Validation failed', 'errors' => $validator->errors()], 422);
        }

        $area = Area::create([
            'user_id' => $user->id,
            'name' => $request->name,
            'trigger_service' => $request->trigger_service,
            'trigger_action' => $request->trigger_action,
            'trigger_params' => $request->trigger_params ?? null,
            'action_service' => $request->action_service,
            'action_reaction' => $request->action_reaction,
            'action_params' => $request->action_params ?? null,
            'is_active' => true,
        ]);

        return response()->json(['message' => 'AREA created successfully', 'area' => $area], 201);
    }

    /**
     * Delete an AREA
     *
     * @group AREAs
     * @authenticated
     *
     * @response 200 {
     *  "message": "AREA deleted successfully"
     * }
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $area = Area::where('id', $id)->where('user_id', $user->id)->first();

        if (! $area) {
            return response()->json(['message' => 'AREA not found'], 404);
        }

        $area->delete();

        return response()->json(['message' => 'AREA deleted successfully'], 200);
    }

    /**
     * Toggle AREA active state
     *
     * @group AREAs
     * @authenticated
     *
     * @response 200 {
     *  "message": "AREA status updated",
     *  "is_active": true
     * }
     */
    public function toggle(Request $request, $id)
    {
        $user = $request->user();
        $area = Area::where('id', $id)->where('user_id', $user->id)->first();

        if (! $area) {
            return response()->json(['message' => 'AREA not found'], 404);
        }

        $area->is_active = ! $area->is_active;
        $area->save();

        return response()->json(['message' => 'AREA status updated', 'is_active' => $area->is_active], 200);
    }

    /**
     * Get details of a specific AREA
     *
     * @group AREAs
     * @authenticated
     *
     * @urlParam id integer required The ID of the AREA. Example: 1
     *
     * @response 200 {
     *  "area": {
     *    "id": 1,
     *    "name": "Sync Calendar to Discord",
     *    "trigger_service": "google",
     *    "trigger_action": "new_event",
     *    "trigger_params": {},
     *    "action_service": "discord",
     *    "action_reaction": "send_message",
     *    "action_params": {},
     *    "is_active": true,
     *    "created_at": "2025-12-06T10:00:00Z",
     *    "updated_at": "2025-12-06T10:00:00Z"
     *  }
     * }
     *
     * @response 404 {
     *  "message": "AREA not found"
     * }
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        $area = Area::where('id', $id)->where('user_id', $user->id)->first();

        if (! $area) {
            return response()->json(['message' => 'AREA not found'], 404);
        }

        return response()->json(['area' => $area], 200);
    }

    /**
     * Update an existing AREA
     *
     * @group AREAs
     * @authenticated
     *
     * @urlParam id integer required The ID of the AREA. Example: 1
     *
     * @bodyParam name string optional Name of the AREA. Example: "Updated AREA name"
     * @bodyParam trigger_service string optional Trigger service id. Example: "google"
     * @bodyParam trigger_action string optional Trigger action id. Example: "new_email"
     * @bodyParam trigger_params object optional Trigger parameters
     * @bodyParam action_service string optional Action service id. Example: "slack"
     * @bodyParam action_reaction string optional Action reaction id. Example: "send_message"
     * @bodyParam action_params object optional Action parameters
     * @bodyParam is_active boolean optional Active status. Example: true
     *
     * @response 200 {
     *  "message": "AREA updated successfully",
     *  "area": {
     *    "id": 1,
     *    "name": "Updated AREA name",
     *    "trigger_service": "google",
     *    "trigger_action": "new_email",
     *    "trigger_params": {},
     *    "action_service": "slack",
     *    "action_reaction": "send_message",
     *    "action_params": {},
     *    "is_active": true,
     *    "created_at": "2025-12-06T10:00:00Z",
     *    "updated_at": "2025-12-06T12:00:00Z"
     *  }
     * }
     *
     * @response 404 {
     *  "message": "AREA not found"
     * }
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();
        $area = Area::where('id', $id)->where('user_id', $user->id)->first();

        if (! $area) {
            return response()->json(['message' => 'AREA not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'trigger_service' => 'sometimes|string',
            'trigger_action' => 'sometimes|string',
            'action_service' => 'sometimes|string',
            'action_reaction' => 'sometimes|string',
            'trigger_params' => 'nullable|array',
            'action_params' => 'nullable|array',
            'is_active' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validation failed', 'errors' => $validator->errors()], 422);
        }

        // Update only the fields that were provided
        $area->update($request->only([
            'name',
            'trigger_service',
            'trigger_action',
            'trigger_params',
            'action_service',
            'action_reaction',
            'action_params',
            'is_active',
        ]));

        return response()->json(['message' => 'AREA updated successfully', 'area' => $area], 200);
    }
}
