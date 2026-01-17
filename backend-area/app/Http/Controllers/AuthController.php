<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user
     * 
     * Create a new user account and return an authentication token.
     *
     * @group Authentication
     * @unauthenticated
     * 
     * @bodyParam name string required The user's full name. Example: John Doe
     * @bodyParam email string required The user's email address. Example: john@example.com
     * @bodyParam password string required The user's password (minimum 6 characters). Example: secret123
     * @bodyParam password_confirmation string required Password confirmation. Example: secret123
     * 
     * @response 201 {
     *   "message": "User registered successfully",
     *   "access_token": "1|abcdefghijklmnopqrstuvwxyz123456",
     *   "token_type": "Bearer",
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com",
     *     "created_at": "2024-12-05T10:00:00.000000Z"
     *   }
     * }
     * 
     * @response 422 {
     *   "message": "Validation failed",
     *   "errors": {
     *     "email": ["The email has already been taken."]
     *   }
     * }
     */
    public function register(Request $request)
    {
        try {
            // Validation
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|max:255|unique:users',
                'password' => 'required|string|min:6|confirmed',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Create user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
            ]);

            // Create token
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'User registered successfully',
                'access_token' => $token,
                'token_type' => 'Bearer',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Registration failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Login user
     * 
     * Authenticate a user and return an access token.
     *
     * @group Authentication
     * @unauthenticated
     * 
     * @bodyParam email string required The user's email address. Example: john@example.com
     * @bodyParam password string required The user's password. Example: secret123
     * 
     * @response 200 {
     *   "message": "Login successful",
     *   "access_token": "1|abcdefghijklmnopqrstuvwxyz123456",
     *   "token_type": "Bearer",
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com"
     *   }
     * }
     * 
     * @response 401 {
     *   "message": "Invalid credentials"
     * }
     * 
     * @response 422 {
     *   "message": "Validation failed",
     *   "errors": {
     *     "email": ["The email field is required."]
     *   }
     * }
     */
    public function login(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|email',
                'password' => 'required',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = User::where('email', $request->email)->first();

            if (!$user || !Hash::check($request->password, $user->password)) {
                return response()->json([
                    'message' => 'Invalid credentials'
                ], 401);
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Login successful',
                'access_token' => $token,
                'token_type' => 'Bearer',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Login failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Google authentication for mobile
     * 
     * Authenticate a user using Google OAuth token.
     *
     * @group Authentication
     * @unauthenticated
     * 
     * @bodyParam token string required Google ID token. Example: eyJhbGciOiJSUzI1NiIsImtpZCI6ImFiY...
     * @bodyParam access_token string Optional Google access token. Example: ya29.a0AfH6SMBx...
     * 
     * @response 200 {
     *   "message": "Login successful",
     *   "access_token": "1|abcdefghijklmnopqrstuvwxyz123456",
     *   "token_type": "Bearer",
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com",
     *     "google_id": "1234567890"
     *   }
     * }
     * 
     * @response 401 {
     *   "message": "Invalid Google token"
     * }
     */
    public function googleAuth(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'token' => 'required|string',
                'access_token' => 'sometimes|string', // Token d'accès Google optionnel
                'refresh_token' => 'sometimes|string', // Refresh token Google optionnel
                'expires_in' => 'sometimes|integer', // Durée de validité en secondes
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Token is required',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Décoder le token JWT pour voir son contenu (sans vérification)
            try {
                $tokenParts = explode('.', $request->token);
                if (count($tokenParts) === 3) {
                    $tokenPayload = json_decode(base64_decode(strtr($tokenParts[1], '-_', '+/')), true);
                    \Log::info('Token decoded', [
                        'aud' => $tokenPayload['aud'] ?? 'not set',
                        'iss' => $tokenPayload['iss'] ?? 'not set',
                        'email' => $tokenPayload['email'] ?? 'not set',
                    ]);
                }
            } catch (\Exception $e) {
                \Log::error('Failed to decode token', ['error' => $e->getMessage()]);
            }

            // Essayer d'abord avec le Client ID Android
            $client = new \Google_Client(['client_id' => env('GOOGLE_WEB_CLIENT_ID')]);
            $payload = $client->verifyIdToken($request->token);

            // Si échec, essayer avec le Mobile Web Client ID (type 3 du google-services.json)
            if (!$payload && env('GOOGLE_MOBILE_WEB_CLIENT_ID')) {
                $client = new \Google_Client(['client_id' => env('GOOGLE_MOBILE_WEB_CLIENT_ID')]);
                $payload = $client->verifyIdToken($request->token);
            }

            if (!$payload) {
                \Log::error('Google token validation failed', [
                    'android_client_id' => env('GOOGLE_WEB_CLIENT_ID'),
                    'mobile_web_client_id' => env('GOOGLE_MOBILE_WEB_CLIENT_ID'),
                    'token_preview' => substr($request->token, 0, 50) . '...',
                ]);
                
                return response()->json([
                    'message' => 'Invalid Google token'
                ], 401);
            }

            // Chercher l'utilisateur par email d'abord
            $user = User::where('email', $payload['email'])->first();

            $updateData = [
                'google_id' => $payload['sub'],
                'email_verified_at' => $user?->email_verified_at ?? now(),
            ];

            // Si un access_token Google est fourni, le sauvegarder
            if ($request->has('access_token') && $request->access_token) {
                $updateData['google_token'] = $request->access_token;
            }

            if ($user) {
                // L'utilisateur existe déjà (inscrit via register), on met à jour avec Google ID
                $user->update($updateData);
            } else {
                // Nouvel utilisateur via Google
                $user = User::create([
                    'name' => $payload['name'],
                    'email' => $payload['email'],
                    ...$updateData
                ]);
            }

            // Mettre à jour user_services avec le token OAuth Google
            if ($request->has('access_token') && $request->access_token) {
                $googleService = \App\Models\Service::where('name', 'google')->first();
                if ($googleService) {
                    \App\Models\UserService::updateOrCreate(
                        [
                            'user_id' => $user->id,
                            'service_id' => $googleService->id,
                        ],
                        [
                            'access_token' => $request->access_token,
                            'refresh_token' => $request->refresh_token ?? null, // Si disponible
                            'expires_at' => now()->addSeconds($request->expires_in ?? 3600),
                        ]
                    );
                    \Log::info('[AuthController] Token OAuth Google mis à jour pour user ' . $user->id);
                }
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Google authentication successful',
                'access_token' => $token,
                'token' => $token,
                'token_type' => 'Bearer',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Google authentication failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Logout user
     * 
     * Revoke the current access token.
     *
     * @group Authentication
     * @authenticated
     * 
     * @response 200 {
     *   "message": "Logged out successfully"
     * }
     */
    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();
            return response()->json([
                'message' => 'Logged out successfully'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Logout failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get authenticated user
     * 
     * Retrieve the currently authenticated user's information.
     *
     * @group Authentication
     * @authenticated
     * 
     * @response 200 {
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com",
     *     "google_id": null,
     *     "email_verified_at": "2024-12-05T10:00:00.000000Z",
     *     "created_at": "2024-12-05T10:00:00.000000Z",
     *     "updated_at": "2024-12-05T10:00:00.000000Z"
     *   }
     * }
     */
    public function user(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ], 200);
    }

    /**
     * Update user profile
     * 
     * Update the authenticated user's profile information.
     *
     * @group Authentication
     * @authenticated
     * 
     * @bodyParam name string The user's full name. Example: Jane Doe
     * @bodyParam email string The user's email address. Example: jane@example.com
     * 
     * @response 200 {
     *   "message": "Profile updated successfully",
     *   "user": {
     *     "id": 1,
     *     "name": "Jane Doe",
     *     "email": "jane@example.com",
     *     "created_at": "2024-12-05T10:00:00.000000Z",
     *     "updated_at": "2024-12-05T11:00:00.000000Z"
     *   }
     * }
     * 
     * @response 422 {
     *   "message": "Validation failed",
     *   "errors": {
     *     "email": ["The email has already been taken."]
     *   }
     * }
     */
    public function updateProfile(Request $request)
    {
        try {
            $user = $request->user();
            
            $validator = Validator::make($request->all(), [
                'name' => 'sometimes|string|max:255',
                'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            if ($request->has('name')) {
                $user->name = $request->name;
            }
            
            if ($request->has('email')) {
                $user->email = $request->email;
            }

            $user->save();

            return response()->json([
                'message' => 'Profile updated successfully',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Profile update failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete user account
     * 
     * Permanently delete the authenticated user's account and all associated data.
     *
     * @group Authentication
     * @authenticated
     * 
     * @response 200 {
     *   "message": "Account deleted successfully"
     * }
     */
    public function deleteAccount(Request $request)
    {
        try {
            $user = $request->user();
            
            // Delete all user's tokens
            $user->tokens()->delete();
            
            // Delete user
            $user->delete();

            return response()->json([
                'message' => 'Account deleted successfully'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Account deletion failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Redirect to Google OAuth (Web)
     */
    public function redirectToGoogle()
    {
        $clientId = env('GOOGLE_WEB_CLIENT_ID');
        $redirectUri = env('GOOGLE_REDIRECT_URI', 'http://localhost:8080/auth/google/callback');
        
        $scopes = [
            'openid',
            'email',
            'profile',
            'https://www.googleapis.com/auth/calendar.readonly', // Accès lecture seule au calendrier
        ];
        
        $url = "https://accounts.google.com/o/oauth2/v2/auth?" . http_build_query([
            'client_id' => $clientId,
            'redirect_uri' => $redirectUri,
            'response_type' => 'code',
            'scope' => implode(' ', $scopes),
            'access_type' => 'offline',
            'prompt' => 'consent', // Force le consentement pour obtenir le refresh token
        ]);

        return redirect($url);
    }

    /**
     * Handle Google OAuth callback (Web)
     */
    public function handleGoogleCallback(Request $request)
    {
        try {
            if (!$request->has('code')) {
                \Log::error('No code in Google callback', ['request' => $request->all()]);
                return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/login?error=no_code');
            }

            $code = $request->code;

            // Exchange code for access token
            $tokenResponse = \Http::post('https://oauth2.googleapis.com/token', [
                'code' => $code,
                'client_id' => env('GOOGLE_WEB_CLIENT_ID'),
                'client_secret' => env('GOOGLE_CLIENT_SECRET'),
                'redirect_uri' => env('GOOGLE_REDIRECT_URI', 'http://localhost:8080/auth/google/callback'),
                'grant_type' => 'authorization_code',
            ]);

            if (!$tokenResponse->successful()) {
                \Log::error('Failed to exchange code for token', ['response' => $tokenResponse->body()]);
                return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/login?error=token_exchange_failed');
            }

            $tokenData = $tokenResponse->json();
            $accessToken = $tokenData['access_token'];
            $refreshToken = $tokenData['refresh_token'] ?? null;

            // Get user info from Google
            $userResponse = \Http::withToken($accessToken)->get('https://www.googleapis.com/oauth2/v2/userinfo');

            if (!$userResponse->successful()) {
                \Log::error('Failed to get user info', ['response' => $userResponse->body()]);
                return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/login?error=user_info_failed');
            }

            $googleUser = $userResponse->json();

            // Find or create user
            $user = User::where('email', $googleUser['email'])->first();

            $updateData = [
                'google_id' => $googleUser['id'],
                'google_token' => $accessToken,
                'email_verified_at' => now(),
            ];

            // Sauvegarder le refresh token s'il existe
            if ($refreshToken) {
                $updateData['google_refresh_token'] = $refreshToken;
            }

            if ($user) {
                $user->update($updateData);
            } else {
                $user = User::create([
                    'name' => $googleUser['name'],
                    'email' => $googleUser['email'],
                    ...$updateData
                ]);
            }

            // Create API token
            $apiToken = $user->createToken('auth_token')->plainTextToken;

            // Redirect to frontend with token
            return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/dashboard?token=' . urlencode($apiToken));

        } catch (\Exception $e) {
            \Log::error('OAuth Error:', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return redirect(env('FRONTEND_URL', 'http://localhost:8081') . '/login?error=' . urlencode($e->getMessage() ?: 'auth_error'));
        }
    }
}