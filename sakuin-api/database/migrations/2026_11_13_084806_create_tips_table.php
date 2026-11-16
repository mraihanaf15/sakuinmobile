<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('tips', function (Blueprint $t) {
            $t->id();
            $t->string('title', 120);
            $t->text('body');
            $t->string('category', 40)->default('umum');
            $t->boolean('is_published')->default(false);
            $t->timestamp('published_at')->nullable();
            $t->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $t->timestamps();
            $t->index(['is_published', 'published_at']);
        });
    }

    public function down(): void { Schema::dropIfExists('tips'); }
};