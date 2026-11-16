<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('budget_settings', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $t->decimal('monthly_income', 15, 2)->default(0);
            $t->unsignedTinyInteger('needs_pct')->default(50);
            $t->unsignedTinyInteger('wants_pct')->default(30);
            $t->unsignedTinyInteger('savings_pct')->default(20);
            $t->timestamps();
        });

        Schema::create('categories', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->nullable()->constrained()->cascadeOnDelete();
            $t->string('name');
            $t->string('icon')->nullable();
            $t->enum('type', ['income', 'expense'])->default('expense');
            $t->enum('bucket', ['needs', 'wants', 'savings'])->nullable();
            $t->boolean('is_default')->default(false);
            $t->timestamps();
        });

        Schema::create('transactions', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->foreignId('category_id')->nullable()->constrained()->nullOnDelete();
            $t->enum('type', ['income', 'expense']);
            $t->string('source')->nullable();
            $t->enum('bucket', ['needs', 'wants', 'savings'])->nullable();
            $t->decimal('amount', 15, 2);
            $t->date('transaction_date');
            $t->text('note')->nullable();
            $t->string('receipt_path')->nullable();
            $t->boolean('is_recurring')->default(false);
            $t->timestamps();
            $t->index(['user_id', 'transaction_date']);
        });

        Schema::create('saving_goals', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('name');
            $t->decimal('target_amount', 15, 2);
            $t->decimal('current_amount', 15, 2)->default(0);
            $t->date('deadline')->nullable();
            $t->timestamps();
        });

        Schema::create('user_notifications', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('type');
            $t->string('title');
            $t->text('body');
            $t->timestamp('read_at')->nullable();
            $t->timestamps();
        });

        Schema::create('ai_logs', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->text('question');
            $t->text('answer');
            $t->string('status')->nullable();
            $t->unsignedTinyInteger('score')->nullable();
            $t->timestamps();
        });

        Schema::create('password_otps', function (Blueprint $t) {
            $t->id();
            $t->string('email')->index();
            $t->string('otp');
            $t->timestamp('expires_at');
            $t->timestamps();
        });
    }
    public function down(): void
    {
        foreach (['password_otps','ai_logs','user_notifications','saving_goals','transactions','categories','budget_settings'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};