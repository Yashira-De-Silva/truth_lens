<?php

namespace Database\Factories;

use App\Models\NewsArticle;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<NewsArticle>
 */
class NewsArticleFactory extends Factory
{
    protected $model = NewsArticle::class;

    public function definition(): array
    {
        return [
            'title' => $this->faker->sentence(8),
            'text' => $this->faker->paragraphs(3, true),
            'subject' => $this->faker->randomElement(['Dataset', 'worldnews', 'politics', 'sports']),
            'date' => $this->faker->date('Y-m-d'),
            'is_fake' => $this->faker->boolean(30),
        ];
    }
}
