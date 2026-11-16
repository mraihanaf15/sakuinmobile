<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('admin_activity_logs', function (Blueprint $t) {
            $t->id();
            $t->foreignId('admin_id')->nullable()->constrained('users')->nullOnDelete();
            $t->string('action', 60);
            $t->string('subject_type', 60)->nullable();
            $t->unsignedBigInteger('subject_id')->nullable();
            $t->string('description', 255);
            $t->json('metadata')->nullable();
            $t->string('ip_address', 45)->nullable();
            $t->string('user_agent', 255)->nullable();
            $t->timestamp('created_at')->useCurrent();
            $t->index(['action', 'created_at']);
            $t->index('admin_id');
        });
    }

    public function down(): void { Schema::dropIfExists('admin_activity_logs'); }
};