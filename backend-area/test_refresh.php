<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "Test du refresh de token pour user 10...\n";

try {
    $user = App\Models\User::find(10);
    if (!$user) {
        echo "Utilisateur 10 non trouvé\n";
        exit(1);
    }
    
    echo "Utilisateur: {$user->name}\n";
    
    $client = App\Helpers\OAuthHelper::getValidGoogleClient($user);
    
    if ($client->isAccessTokenExpired()) {
        echo "Token EXPIRÉ (refresh a échoué)\n";
        exit(1);
    } else {
        echo "✅ Token VALIDE (refresh réussi)\n";
        
        // Vérifier la nouvelle date d'expiration
        $userService = App\Models\UserService::where('user_id', 10)
            ->where('service_id', 1)
            ->first();
        echo "Nouvelle expiration: {$userService->expires_at}\n";
    }
    
} catch (\Exception $e) {
    echo "❌ ERREUR: {$e->getMessage()}\n";
    exit(1);
}
