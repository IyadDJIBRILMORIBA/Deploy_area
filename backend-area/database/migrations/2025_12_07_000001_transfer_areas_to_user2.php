<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Mettre à jour toutes les AREAs de l'user 1 vers l'user 2
        DB::table('areas')->where('user_id', 1)->update(['user_id' => 2]);
        echo "AREAs transférées de l'user 1 vers l'user 2\n";
    }

    public function down()
    {
        // Revenir en arrière
        DB::table('areas')->where('user_id', 2)->update(['user_id' => 1]);
    }
};
