<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\GitHubService;
use Illuminate\Support\Facades\Http;

class GitHubServiceTest extends TestCase
{
    protected GitHubService $githubService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->githubService = new GitHubService();
    }

    /**
     * Test que checkNewIssue retourne false si le repo est manquant
     */
    public function test_check_new_issue_returns_false_when_repo_missing(): void
    {
        $result = $this->githubService->checkTrigger('new_issue', [], null);
        
        $this->assertFalse($result);
    }

    /**
     * Test que checkNewIssue détecte une nouvelle issue
     */
    public function test_check_new_issue_detects_new_issue(): void
    {
        Http::fake([
            'api.github.com/repos/*' => Http::response([
                [
                    'number' => 123,
                    'title' => 'Bug report',
                    'state' => 'open',
                    'html_url' => 'https://github.com/owner/repo/issues/123',
                    'user' => ['login' => 'testuser']
                ]
            ], 200)
        ]);

        $result = $this->githubService->checkTrigger('new_issue', [
            'repo' => 'owner/repo',
            'access_token' => 'ghp_test_token'
        ], null);

        $this->assertIsArray($result);
        $this->assertEquals(123, $result['issue_number']);
        $this->assertEquals('Bug report', $result['issue_title']);
    }

    /**
     * Test que checkNewIssue ignore les issues déjà traitées
     */
    public function test_check_new_issue_ignores_already_processed(): void
    {
        Http::fake([
            'api.github.com/repos/*' => Http::response([
                [
                    'number' => 123,
                    'title' => 'Old issue',
                    'state' => 'open'
                ]
            ], 200)
        ]);

        $result = $this->githubService->checkTrigger('new_issue', [
            'repo' => 'owner/repo',
            'access_token' => 'ghp_test_token',
            'last_issue_id' => 123
        ], null);

        $this->assertFalse($result);
    }

    /**
     * Test la création d'une issue
     */
    public function test_create_issue_successfully(): void
    {
        Http::fake([
            'api.github.com/repos/*/issues' => Http::response([
                'number' => 456,
                'title' => 'New issue',
                'html_url' => 'https://github.com/owner/repo/issues/456'
            ], 201)
        ]);

        $result = $this->githubService->executeReaction('create_issue', [
            'repo' => 'owner/repo',
            'title' => 'New issue',
            'body' => 'Issue description',
            'access_token' => 'ghp_test_token'
        ], null, []);

        $this->assertTrue($result);
    }

    /**
     * Test la gestion des erreurs d'authentification
     */
    public function test_handles_auth_errors(): void
    {
        Http::fake([
            'api.github.com/*' => Http::response(['message' => 'Bad credentials'], 401)
        ]);

        $result = $this->githubService->checkTrigger('new_issue', [
            'repo' => 'owner/repo',
            'access_token' => 'invalid_token'
        ], null);

        $this->assertFalse($result);
    }
}
