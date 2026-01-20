<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Services\SlackService;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SlackServiceTest extends TestCase
{
    protected SlackService $slackService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->slackService = new SlackService();
    }

    /**
     * Test que checkNewMessage retourne false si les paramètres sont manquants
     */
    public function test_check_new_message_returns_false_when_params_missing(): void
    {
        $result = $this->slackService->checkTrigger('new_message', [], null);
        
        $this->assertFalse($result);
    }

    /**
     * Test que checkNewMessage détecte un nouveau message
     */
    public function test_check_new_message_detects_new_message(): void
    {
        Http::fake([
            'slack.com/api/conversations.history*' => Http::response([
                'ok' => true,
                'messages' => [
                    [
                        'ts' => '1234567890.123456',
                        'text' => 'Hello World',
                        'user' => 'U123456',
                        'type' => 'message'
                    ]
                ]
            ], 200)
        ]);

        $result = $this->slackService->checkTrigger('new_message', [
            'bot_token' => 'xoxb-test-token',
            'channel_id' => 'C123456'
        ], null);

        $this->assertIsArray($result);
        $this->assertEquals('1234567890.123456', $result['timestamp']);
        $this->assertEquals('Hello World', $result['text']);
    }

    /**
     * Test que checkNewMessage ignore les messages déjà traités
     */
    public function test_check_new_message_ignores_already_processed(): void
    {
        Http::fake([
            'slack.com/api/conversations.history*' => Http::response([
                'ok' => true,
                'messages' => [
                    [
                        'ts' => '1234567890.123456',
                        'text' => 'Hello',
                        'user' => 'U123456'
                    ]
                ]
            ], 200)
        ]);

        $result = $this->slackService->checkTrigger('new_message', [
            'bot_token' => 'xoxb-test-token',
            'channel_id' => 'C123456',
            'last_timestamp' => '1234567890.123456'
        ], null);

        $this->assertFalse($result);
    }

    /**
     * Test que checkMessageContains trouve un mot-clé
     */
    public function test_check_message_contains_finds_keyword(): void
    {
        Http::fake([
            'slack.com/api/conversations.history*' => Http::response([
                'ok' => true,
                'messages' => [
                    [
                        'ts' => '1234567890.123456',
                        'text' => 'Urgent: Server down!',
                        'user' => 'U123456'
                    ]
                ]
            ], 200)
        ]);

        $result = $this->slackService->checkTrigger('message_contains', [
            'bot_token' => 'xoxb-test-token',
            'channel_id' => 'C123456',
            'keyword' => 'Urgent'
        ], null);

        $this->assertIsArray($result);
        $this->assertArrayNotHasKey('_skip', $result);
        $this->assertStringContainsString('Urgent', $result['text']);
    }

    /**
     * Test que checkMessageContains retourne skip si mot-clé absent
     */
    public function test_check_message_contains_skips_when_keyword_not_found(): void
    {
        Http::fake([
            'slack.com/api/conversations.history*' => Http::response([
                'ok' => true,
                'messages' => [
                    [
                        'ts' => '1234567890.123456',
                        'text' => 'Normal message',
                        'user' => 'U123456'
                    ]
                ]
            ], 200)
        ]);

        $result = $this->slackService->checkTrigger('message_contains', [
            'bot_token' => 'xoxb-test-token',
            'channel_id' => 'C123456',
            'keyword' => 'Urgent'
        ], null);

        $this->assertIsArray($result);
        $this->assertTrue($result['_skip'] ?? false);
        $this->assertArrayHasKey('timestamp', $result);
    }

    /**
     * Test de l'envoi de message
     */
    public function test_send_message_successfully(): void
    {
        Http::fake([
            'slack.com/api/chat.postMessage*' => Http::response([
                'ok' => true,
                'ts' => '1234567890.123456'
            ], 200)
        ]);

        $result = $this->slackService->executeReaction('send_message', [
            'bot_token' => 'xoxb-test-token',
            'channel' => '#general',
            'text' => 'Test message'
        ], null, []);

        $this->assertTrue($result);
    }
}
