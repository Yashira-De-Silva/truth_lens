<?php

namespace Tests\Feature;

use App\Models\NewsArticle;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NewsFeedMixTest extends TestCase
{
    use RefreshDatabase;

    public function test_news_feed_returns_a_mix_of_real_and_fake(): void
    {
        NewsArticle::factory()->create(['is_fake' => false, 'title' => 'Real 1', 'text' => 'a', 'subject' => 'Dataset', 'date' => '2017-08-22']);
        NewsArticle::factory()->create(['is_fake' => false, 'title' => 'Real 2', 'text' => 'a', 'subject' => 'Dataset', 'date' => '2017-08-22']);
        NewsArticle::factory()->create(['is_fake' => true,  'title' => 'Fake 1', 'text' => 'a', 'subject' => 'Dataset', 'date' => '2017-08-22']);
        NewsArticle::factory()->create(['is_fake' => true,  'title' => 'Fake 2', 'text' => 'a', 'subject' => 'Dataset', 'date' => '2017-08-22']);

        $res = $this->getJson('/api/news?limit=4&fake_ratio=0.5');
        $res->assertStatus(200);

        $data = $res->json('data');
        $this->assertIsArray($data);
        $this->assertCount(4, $data);

        $labels = array_map(fn ($a) => $a['label'] ?? null, $data);
        $this->assertContains('REAL', $labels);
        $this->assertContains('FAKE', $labels);
    }

    public function test_news_feed_is_fake_filter_returns_only_fake(): void
    {
        NewsArticle::factory()->create(['is_fake' => false, 'title' => 'Real', 'text' => 'a', 'subject' => 'Dataset', 'date' => '2017-08-22']);
        NewsArticle::factory()->create(['is_fake' => true,  'title' => 'Fake', 'text' => 'a', 'subject' => 'Dataset', 'date' => '2017-08-22']);

        $res = $this->getJson('/api/news?limit=10&is_fake=1');
        $res->assertStatus(200);

        $data = $res->json('data');
        foreach ($data as $item) {
            $this->assertSame('FAKE', $item['label']);
        }
    }
}
