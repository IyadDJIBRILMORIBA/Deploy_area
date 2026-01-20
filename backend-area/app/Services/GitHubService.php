<?php

namespace App\Services;

use App\Interfaces\ServiceInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GitHubService implements ServiceInterface
{
    private const API_BASE = 'https://api.github.com';
    
    /**
     * Récupère le token GitHub de l'utilisateur
     */
    private function getAccessToken($user)
    {
        $githubService = $user->services()
            ->where('services.name', 'github')
            ->first();
            
        if (!$githubService) {
            throw new \Exception("GitHub non connecté pour user {$user->id}");
        }
        
        return $githubService->pivot->access_token;
    }
    
    /**
     * Vérifie les triggers GitHub
     * 
     * @param string $actionName Le nom du trigger
     * @param array $params Paramètres (repo, last_issue_id, last_pr_id, branch, last_commit_sha)
     * @param object|null $userToken L'objet User
     * @return bool|array Retourne false ou les données du trigger
     */
    public function checkTrigger(string $actionName, array $params, $userToken)
    {
        try {
            $accessToken = $this->getAccessToken($userToken);
            
            // Convertir le nom du trigger en snake_case pour comparaison
            $triggerKey = strtolower(str_replace(' ', '_', $actionName));
            
            // Trigger 1: Nouvelle issue créée
            if (in_array($triggerKey, ['new_issue', 'new_issue_created', 'new_issues_created'])) {
                return $this->checkNewIssue($accessToken, $params);
            }
            
            // Trigger 2: Nouvelle pull request
            if ($triggerKey === 'new_pull_request' || $triggerKey === 'new_pr') {
                return $this->checkNewPullRequest($accessToken, $params);
            }
            
            // Trigger 3: Nouveau commit
            if ($triggerKey === 'new_commit') {
                return $this->checkNewCommit($accessToken, $params);
            }
            
            // Trigger 4: Repo reçoit une star
            if ($triggerKey === 'repo_starred') {
                return $this->checkRepoStarred($accessToken, $params);
            }
            
            return false;
            
        } catch (\Exception $e) {
            Log::error("[GitHubService] Erreur checkTrigger: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Vérifie si une nouvelle issue a été créée
     */
    private function checkNewIssue($accessToken, $params)
    {
        $repo = $params['repository'] ?? $params['repo'] ?? null;
        
        if (!$repo) {
            Log::error("[GitHubService] repo manquant pour new_issue");
            return false;
        }
        
        Log::info("[GitHubService] Checking issues for repo: {$repo}");
        
        $response = Http::withToken($accessToken)
            ->accept('application/vnd.github.v3+json')
            ->get(self::API_BASE . "/repos/{$repo}/issues", [
                'state' => 'open',
                'sort' => 'created',
                'direction' => 'desc',
                'per_page' => 1,
            ]);
            
        if (!$response->successful()) {
            Log::error("[GitHubService] Erreur API issues: " . $response->status() . " - " . $response->body());
            return false;
        }
        
        $issues = $response->json();
        
        Log::info("[GitHubService] Issues récupérées: " . count($issues));
        
        if (empty($issues)) {
            Log::info("[GitHubService] Aucune issue trouvée");
            return false;
        }
        
        $latestIssue = $issues[0];
        
        Log::info("[GitHubService] Dernière issue: #{$latestIssue['number']} - {$latestIssue['title']}");
        
        // Ignorer les pull requests (GitHub les retourne aussi dans /issues)
        if (isset($latestIssue['pull_request'])) {
            Log::info("[GitHubService] Issue ignorée (c'est une PR)");
            return false;
        }
        
        $issueNumber = $latestIssue['number'];
        $lastIssueId = $params['last_issue_id'] ?? null;
        
        Log::info("[GitHubService] Issue actuelle: #{$issueNumber}, dernière vue: " . ($lastIssueId ?? 'aucune'));
        
        if ($lastIssueId && $issueNumber <= $lastIssueId) {
            Log::info("[GitHubService] Issue déjà vue (#{$issueNumber} <= #{$lastIssueId})");
            return false;
        }
        
        Log::info("[GitHubService] Nouvelle issue #{$issueNumber}: {$latestIssue['title']}");
        
        return [
            'issue_number' => $issueNumber,
            'issue_title' => $latestIssue['title'],
            'issue_body' => $latestIssue['body'] ?? '',
            'issue_url' => $latestIssue['html_url'],
            'issue_state' => $latestIssue['state'],
            'author' => $latestIssue['user']['login'],
            'created_at' => $latestIssue['created_at'],
        ];
    }
    
    /**
     * Vérifie si une nouvelle pull request a été créée
     */
    private function checkNewPullRequest($accessToken, $params)
    {
        $repo = $params['repository'] ?? $params['repo'] ?? null;
        
        if (!$repo) {
            Log::error("[GitHubService] repo manquant pour new_pull_request");
            return false;
        }
        
        $response = Http::withToken($accessToken)
            ->accept('application/vnd.github.v3+json')
            ->get(self::API_BASE . "/repos/{$repo}/pulls", [
                'state' => 'open',
                'sort' => 'created',
                'direction' => 'desc',
                'per_page' => 1,
            ]);
            
        if (!$response->successful()) {
            Log::error("[GitHubService] Erreur API pulls: " . $response->status());
            return false;
        }
        
        $pulls = $response->json();
        
        if (empty($pulls)) {
            return false;
        }
        
        $latestPR = $pulls[0];
        $prNumber = $latestPR['number'];
        $lastPrId = $params['last_pr_id'] ?? null;
        
        if ($lastPrId && $prNumber <= $lastPrId) {
            return false;
        }
        
        Log::info("[GitHubService] Nouvelle PR #{$prNumber}: {$latestPR['title']}");
        
        return [
            'pr_number' => $prNumber,
            'pr_title' => $latestPR['title'],
            'pr_body' => $latestPR['body'] ?? '',
            'pr_url' => $latestPR['html_url'],
            'pr_state' => $latestPR['state'],
            'author' => $latestPR['user']['login'],
            'branch' => $latestPR['head']['ref'],
            'created_at' => $latestPR['created_at'],
        ];
    }
    
    /**
     * Vérifie si un nouveau commit a été poussé
     */
    private function checkNewCommit($accessToken, $params)
    {
        $repo = $params['repository'] ?? $params['repo'] ?? null;
        $branch = $params['branch'] ?? 'main';
        
        if (!$repo) {
            Log::error("[GitHubService] repo manquant pour new_commit");
            return false;
        }
        
        $response = Http::withToken($accessToken)
            ->accept('application/vnd.github.v3+json')
            ->get(self::API_BASE . "/repos/{$repo}/commits", [
                'sha' => $branch,
                'per_page' => 1,
            ]);
            
        if (!$response->successful()) {
            Log::error("[GitHubService] Erreur API commits: " . $response->status());
            return false;
        }
        
        $commits = $response->json();
        
        if (empty($commits)) {
            return false;
        }
        
        $latestCommit = $commits[0];
        $commitSha = $latestCommit['sha'];
        $lastCommitSha = $params['last_commit_sha'] ?? null;
        
        if ($lastCommitSha === $commitSha) {
            return false;
        }
        
        Log::info("[GitHubService] Nouveau commit sur {$branch}: {$latestCommit['commit']['message']}");
        
        return [
            'commit_sha' => $commitSha,
            'commit_message' => $latestCommit['commit']['message'],
            'commit_url' => $latestCommit['html_url'],
            'author' => $latestCommit['commit']['author']['name'],
            'branch' => $branch,
            'created_at' => $latestCommit['commit']['author']['date'],
        ];
    }
    
    /**
     * Vérifie si le repo a reçu une nouvelle star
     */
    private function checkRepoStarred($accessToken, $params)
    {
        $repo = $params['repository'] ?? $params['repo'] ?? null;
        
        if (!$repo) {
            Log::error("[GitHubService] repo manquant pour repo_starred");
            return false;
        }
        
        $response = Http::withToken($accessToken)
            ->accept('application/vnd.github.v3+json')
            ->get(self::API_BASE . "/repos/{$repo}");
            
        if (!$response->successful()) {
            Log::error("[GitHubService] Erreur API repo: " . $response->status());
            return false;
        }
        
        $repoData = $response->json();
        $currentStars = $repoData['stargazers_count'];
        $lastStarCount = $params['last_star_count'] ?? 0;
        
        if ($currentStars <= $lastStarCount) {
            return false;
        }
        
        Log::info("[GitHubService] Nouvelle(s) star(s) sur {$repo}: {$currentStars} (avant: {$lastStarCount})");
        
        return [
            'star_count' => $currentStars,
            'repo_name' => $repoData['full_name'],
            'repo_url' => $repoData['html_url'],
            'stars_gained' => $currentStars - $lastStarCount,
        ];
    }
    
    /**
     * Exécute les réactions GitHub
     * 
     * @param string $reactionName Le nom de la réaction
     * @param array $params Paramètres de la réaction
     * @param object|null $userToken L'objet User
     * @param array $triggerData Les données du trigger
     * @return bool True si succès
     */
    public function executeReaction(string $reactionName, array $params, $userToken, array $triggerData)
    {
        try {
            $accessToken = $this->getAccessToken($userToken);
            
            // Convertir le nom de la réaction en snake_case pour comparaison
            $actionKey = strtolower(str_replace(' ', '_', $reactionName));
            
            // Réaction 1: Créer une issue
            if ($actionKey === 'create_issue') {
                return $this->createIssue($accessToken, $params, $triggerData);
            }
            
            // Réaction 2: Commenter une issue
            if ($actionKey === 'comment_issue') {
                return $this->commentIssue($accessToken, $params, $triggerData);
            }
            
            // Réaction 3: Fermer une issue
            if ($reactionName === 'close_issue') {
                return $this->closeIssue($accessToken, $params, $triggerData);
            }
            
            return false;
            
        } catch (\Exception $e) {
            Log::error("[GitHubService] Erreur executeReaction: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Crée une nouvelle issue
     */
    private function createIssue($accessToken, $params, $triggerData)
    {
        // Accepter 'repo' ou 'repository'
        $repo = $params['repo'] ?? $params['repository'] ?? null;
        $title = $params['title'] ?? 'Nouvelle issue';
        $body = $params['body'] ?? '';
        
        if (!$repo) {
            Log::error("[GitHubService] repo manquant pour create_issue");
            return false;
        }
        
        Log::info("[GitHubService] Création issue dans {$repo}: {$title}");
        
        // Remplacer les variables dynamiques
        $title = $this->replaceVariables($title, $triggerData);
        $body = $this->replaceVariables($body, $triggerData);
        
        $response = Http::withToken($accessToken)
            ->accept('application/vnd.github.v3+json')
            ->post(self::API_BASE . "/repos/{$repo}/issues", [
                'title' => $title,
                'body' => $body,
            ]);
            
        if ($response->successful()) {
            $issue = $response->json();
            Log::info("[GitHubService] Issue créée #{$issue['number']}: {$title}");
            return true;
        }
        
        Log::error("[GitHubService] Erreur création issue: " . $response->status());
        return false;
    }
    
    /**
     * Commente une issue existante
     */
    private function commentIssue($accessToken, $params, $triggerData)
    {
        $repo = $params['repo'] ?? null;
        $issueNumber = $params['issue_number'] ?? $triggerData['issue_number'] ?? null;
        $comment = $params['comment'] ?? 'Commentaire automatique';
        
        if (!$repo || !$issueNumber) {
            Log::error("[GitHubService] repo ou issue_number manquant pour comment_issue");
            return false;
        }
        
        // Remplacer les variables dynamiques
        $comment = $this->replaceVariables($comment, $triggerData);
        
        $response = Http::withToken($accessToken)
            ->accept('application/vnd.github.v3+json')
            ->post(self::API_BASE . "/repos/{$repo}/issues/{$issueNumber}/comments", [
                'body' => $comment,
            ]);
            
        if ($response->successful()) {
            Log::info("[GitHubService] Commentaire ajouté sur issue #{$issueNumber}");
            return true;
        }
        
        Log::error("[GitHubService] Erreur commentaire issue: " . $response->status());
        return false;
    }
    
    /**
     * Ferme une issue
     */
    private function closeIssue($accessToken, $params, $triggerData)
    {
        $repo = $params['repo'] ?? null;
        $issueNumber = $params['issue_number'] ?? $triggerData['issue_number'] ?? null;
        
        if (!$repo || !$issueNumber) {
            Log::error("[GitHubService] repo ou issue_number manquant pour close_issue");
            return false;
        }
        
        $response = Http::withToken($accessToken)
            ->accept('application/vnd.github.v3+json')
            ->patch(self::API_BASE . "/repos/{$repo}/issues/{$issueNumber}", [
                'state' => 'closed',
            ]);
            
        if ($response->successful()) {
            Log::info("[GitHubService] Issue #{$issueNumber} fermée");
            return true;
        }
        
        Log::error("[GitHubService] Erreur fermeture issue: " . $response->status());
        return false;
    }
    
    /**
     * Remplace les variables dynamiques dans un texte
     * Ex: "Issue: {trigger.issue_title}" devient "Issue: Bug sur le login"
     */
    private function replaceVariables($text, $triggerData)
    {
        foreach ($triggerData as $key => $value) {
            if (is_string($value)) {
                $text = str_replace("{trigger.{$key}}", $value, $text);
                $text = str_replace("{{$key}}", $value, $text);
            }
        }
        
        return $text;
    }
}
