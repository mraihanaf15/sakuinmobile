<?php
namespace Tests\Feature\Admin;

use App\Models\Category;
use App\Models\Setting;
use App\Models\Tip;
use App\Models\Transaction;
use App\Models\User;
use App\Services\ActivityLogger;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminSecurityTest extends TestCase
{
    use RefreshDatabase;

    private function admin(array $a = []): User
    {
        return User::factory()->create(array_merge(['role' => 'admin', 'status' => 'active'], $a));
    }

    private function member(array $a = []): User
    {
        return User::factory()->create(array_merge(['role' => 'user', 'status' => 'active'], $a));
    }

    public function test_guest_is_rejected(): void
    {
        $this->getJson('/api/admin/dashboard')->assertUnauthorized();
    }

    public function test_regular_user_cannot_access_admin_api(): void
    {
        Sanctum::actingAs($this->member());
        foreach (['dashboard', 'users', 'categories', 'tips', 'activity-logs', 'settings'] as $p) {
            $this->getJson("/api/admin/$p")->assertForbidden();
        }
    }

    public function test_suspended_admin_is_rejected(): void
    {
        Sanctum::actingAs($this->admin(['status' => 'suspended']));
        $this->getJson('/api/admin/dashboard')->assertForbidden();
    }

    public function test_admin_dashboard_structure_and_empty_state(): void
    {
        Sanctum::actingAs($this->admin());
        $this->getJson('/api/admin/dashboard')->assertOk()
            ->assertJsonStructure(['users' => ['total', 'active', 'suspended'], 'usage', 'growth', 'daily',
                'recent_activity', 'system' => ['database']])
            ->assertJsonPath('users.total', 0);
    }

    public function test_login_returns_role_and_logs_admin_login(): void
    {
        $a = $this->admin(['password' => 'rahasia123']);
        $this->postJson('/api/login', ['email' => $a->email, 'password' => 'rahasia123'])
            ->assertOk()->assertJsonPath('role', 'admin')->assertJsonPath('user.role', 'admin')
            ->assertJsonStructure(['token']);
        $this->assertDatabaseHas('admin_activity_logs', ['admin_id' => $a->id, 'action' => 'auth.login']);
    }

    public function test_user_login_returns_user_role(): void
    {
        $u = $this->member(['password' => 'rahasia123']);
        $this->postJson('/api/login', ['email' => $u->email, 'password' => 'rahasia123'])
            ->assertOk()->assertJsonPath('role', 'user');
    }

    public function test_login_is_rate_limited(): void
    {
        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/login', ['email' => 'x@sakuin.test', 'password' => 'salah'])->assertStatus(422);
        }
        $this->postJson('/api/login', ['email' => 'x@sakuin.test', 'password' => 'salah'])->assertStatus(429);
    }

    public function test_suspended_user_cannot_login(): void
    {
        $u = $this->member(['status' => 'suspended', 'password' => 'rahasia123']);
        $this->postJson('/api/login', ['email' => $u->email, 'password' => 'rahasia123'])->assertForbidden();
    }

    public function test_register_cannot_create_admin_and_profile_cannot_escalate(): void
    {
        $this->postJson('/api/register', ['name' => 'Eve', 'email' => 'eve@sakuin.test', 'password' => 'password123',
            'password_confirmation' => 'password123', 'role' => 'admin'])
            ->assertCreated()->assertJsonPath('user.role', 'user');

        $u = $this->member();
        Sanctum::actingAs($u);
        $this->putJson('/api/me', ['name' => 'Baru', 'role' => 'admin'])->assertOk();
        $this->assertSame('user', $u->fresh()->role);
    }

    public function test_registration_can_be_closed_by_setting(): void
    {
        Setting::put('registration_open', false);
        $this->postJson('/api/register', ['name' => 'A', 'email' => 'a@sakuin.test', 'password' => 'password123',
            'password_confirmation' => 'password123'])->assertForbidden();
    }

    public function test_admin_suspends_user_revokes_tokens_and_logs(): void
    {
        $admin = $this->admin();
        $u = $this->member();
        $u->createToken('t');

        Sanctum::actingAs($admin);
        $this->patchJson("/api/admin/users/{$u->id}/status", ['status' => 'suspended', 'reason' => 'uji'])->assertOk();

        $this->assertDatabaseHas('users', ['id' => $u->id, 'status' => 'suspended']);
        $this->assertSame(0, $u->tokens()->count());
        $this->assertDatabaseHas('admin_activity_logs', ['action' => 'user.status_changed', 'subject_id' => $u->id]);
    }

    public function test_admin_cannot_change_self_or_other_admin(): void
    {
        $admin = $this->admin();
        $other = $this->admin();
        Sanctum::actingAs($admin);

        $this->patchJson("/api/admin/users/{$other->id}/status", ['status' => 'suspended'])->assertForbidden();
        $this->patchJson("/api/admin/users/{$admin->id}/status", ['status' => 'suspended'])->assertForbidden();
    }

    public function test_user_detail_hides_private_data(): void
    {
        Sanctum::actingAs($this->admin());
        $u = $this->member();
        $res = $this->getJson("/api/admin/users/{$u->id}")->assertOk();
        $res->assertJsonMissingPath('password')->assertJsonStructure(['stats' => ['transactions_count']]);
    }

    public function test_category_in_use_cannot_be_deleted_but_can_be_deactivated(): void
    {
        Sanctum::actingAs($this->admin());
        $u = $this->member();
        $cat = Category::create(['name' => 'Kopi', 'type' => 'expense', 'bucket' => 'wants', 'is_default' => true]);
        Transaction::create(['user_id' => $u->id, 'category_id' => $cat->id, 'type' => 'expense', 'bucket' => 'wants',
            'amount' => 15000, 'transaction_date' => now()->toDateString()]);

        $this->deleteJson("/api/admin/categories/{$cat->id}")->assertStatus(409);
        $this->assertDatabaseHas('categories', ['id' => $cat->id]);

        $this->putJson("/api/admin/categories/{$cat->id}",
            ['name' => 'Kopi', 'type' => 'expense', 'bucket' => 'wants', 'is_active' => false])->assertOk();
        $this->assertDatabaseHas('categories', ['id' => $cat->id, 'is_active' => false]);
    }

    public function test_unused_category_can_be_created_and_deleted(): void
    {
        Sanctum::actingAs($this->admin());
        $id = $this->postJson('/api/admin/categories',
            ['name' => 'Zakat', 'type' => 'expense', 'bucket' => 'needs', 'icon' => 'volunteer'])
            ->assertCreated()->json('id');
        $this->deleteJson("/api/admin/categories/$id")->assertOk();
        $this->assertDatabaseMissing('categories', ['id' => $id]);
    }

    public function test_inactive_category_is_hidden_from_users_and_cannot_be_used(): void
    {
        $hidden = Category::create(['name' => 'Tersembunyi', 'type' => 'expense', 'bucket' => 'wants',
            'is_default' => true, 'is_active' => false]);
        $u = $this->member();
        Sanctum::actingAs($u);

        $this->getJson('/api/categories')->assertOk()->assertJsonMissing(['name' => 'Tersembunyi']);
        $this->postJson('/api/transactions', ['type' => 'expense', 'amount' => 1000,
            'transaction_date' => now()->toDateString(), 'category_id' => $hidden->id])->assertStatus(422);
    }

    public function test_user_cannot_use_another_users_category(): void
    {
        $a = $this->member();
        $b = $this->member();
        $cat = Category::create(['user_id' => $a->id, 'name' => 'Pribadi A', 'type' => 'expense', 'bucket' => 'wants']);

        Sanctum::actingAs($b);
        $this->postJson('/api/transactions', ['type' => 'expense', 'amount' => 1000,
            'transaction_date' => now()->toDateString(), 'category_id' => $cat->id])->assertStatus(422);
    }

    public function test_tips_crud_and_visibility(): void
    {
        $admin = $this->admin();
        Sanctum::actingAs($admin);
        $this->postJson('/api/admin/tips', ['title' => 'Catat tiap hari', 'body' => 'Biasakan mencatat.',
            'category' => 'anggaran', 'is_published' => true])->assertCreated();
        $draft = $this->postJson('/api/admin/tips', ['title' => 'Draf', 'body' => 'Belum terbit.',
            'category' => 'umum'])->assertCreated()->json('id');

        Sanctum::actingAs($this->member());
        $this->getJson('/api/tips')->assertOk()->assertJsonFragment(['title' => 'Catat tiap hari'])
            ->assertJsonMissing(['title' => 'Draf']);

        Sanctum::actingAs($admin);
        $this->patchJson("/api/admin/tips/$draft/publish", ['is_published' => true])->assertOk();
        $this->deleteJson("/api/admin/tips/$draft")->assertOk();
        $this->assertDatabaseHas('admin_activity_logs', ['action' => 'tip.deleted']);
    }

    public function test_tips_strip_html(): void
    {
        Sanctum::actingAs($this->admin());
        $this->postJson('/api/admin/tips', ['title' => '<script>alert(1)</script>Halo', 'body' => 'Isi <b>tebal</b>',
            'category' => 'umum'])->assertCreated();
        $this->assertDatabaseMissing('tips', ['title' => '<script>alert(1)</script>Halo']);
    }

    public function test_activity_log_is_immutable(): void
    {
        $log = ActivityLogger::log($this->admin(), 'test.action', 'uji');
        $this->expectException(\LogicException::class);
        $log->update(['description' => 'diubah']);
    }

    public function test_activity_log_cannot_be_deleted(): void
    {
        $log = ActivityLogger::log($this->admin(), 'test.action', 'uji');
        $this->expectException(\LogicException::class);
        $log->delete();
    }

    public function test_settings_validation(): void
    {
        Sanctum::actingAs($this->admin());
        $this->putJson('/api/admin/settings', ['threshold_sehat' => 60, 'threshold_waspada' => 70])
            ->assertStatus(422);
        $this->putJson('/api/admin/settings', ['threshold_sehat' => 80, 'threshold_waspada' => 55,
            'app_name' => 'Sakuin'])->assertOk()->assertJsonPath('threshold_sehat', 80);
        $this->assertDatabaseHas('admin_activity_logs', ['action' => 'settings.updated']);
    }
}