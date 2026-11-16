<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('users', function (Blueprint $t) {
            $t->string('phone')->nullable()->after('email');
            $t->enum('role', ['admin', 'user'])->default('user')->after('password');
            $t->enum('status', ['active', 'suspended'])->default('active')->after('role');
            $t->timestamp('last_login_at')->nullable();
        });
    }
    public function down(): void
    {
        Schema::table('users', fn (Blueprint $t) => $t->dropColumn(['phone', 'role', 'status', 'last_login_at']));
    }
};