<?php
return [
    'thresholds' => ['sehat' => 75, 'waspada' => 50],
    'warning_percent' => 80,
    'ai' => [
        'key'   => env('ANTHROPIC_API_KEY'),
        'model' => env('ANTHROPIC_MODEL', 'claude-sonnet-5-5'),
    ],
    'suggested_prompts' => [
        'Apakah keuangan saya bulan ini normal?',
        'Di mana pengeluaran terbesar saya?',
        'Bagaimana cara menghemat?',
    ],
];