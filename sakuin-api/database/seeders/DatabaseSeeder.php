<?php
namespace Database\Seeders;

use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::firstOrNew(['email' => env('SEED_ADMIN_EMAIL', 'admin@sakuin.test')]);
        $admin->forceFill([
            'name' => 'Admin Sakuin',
            'password' => env('SEED_ADMIN_PASSWORD', 'password123'),
            'role' => 'admin',
            'status' => 'active',
        ])->save();

        $expense = [
            ['Makan', 'restaurant', 'needs'], ['Transport', 'directions_car', 'needs'], ['Tagihan', 'receipt_long', 'needs'],
            ['Kesehatan', 'favorite', 'needs'], ['Pendidikan', 'school', 'needs'],
            ['Belanja', 'shopping_bag', 'wants'], ['Hiburan', 'movie', 'wants'],
            ['Tabungan', 'savings', 'savings'], ['Investasi', 'trending_up', 'savings'], ['Lainnya', 'more_horiz', 'wants'],
        ];
        foreach ($expense as [$name, $icon, $bucket]) {
            Category::firstOrCreate(['name' => $name, 'type' => 'expense', 'user_id' => null],
                ['icon' => $icon, 'bucket' => $bucket, 'is_default' => true]);
        }
        foreach (['Gaji', 'Bonus', 'Freelance', 'Usaha', 'Hadiah', 'Lainnya'] as $name) {
            Category::firstOrCreate(['name' => $name, 'type' => 'income', 'user_id' => null], ['is_default' => true]);
        }
    }
}