<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $database = DB::getDatabaseName();

        if (empty($database)) {
            return;
        }

        $constraints = DB::table('information_schema.table_constraints')
            ->select('table_name')
            ->where('constraint_schema', $database)
            ->where('constraint_name', 'original_media_id')
            ->get();

        foreach ($constraints as $constraint) {
            DB::statement(sprintf(
                'ALTER TABLE `%s` DROP FOREIGN KEY `original_media_id`',
                $constraint->table_name
            ));
        }
    }

    public function down(): void
    {
        // Intentionally left blank.
    }
};
