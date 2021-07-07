<?php

use App\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // creating an user
        $username = 'demo_admin';
        if (isset($_ENV['ADMIN_USERNAME'])) {
            $username =  $_ENV['ADMIN_USERNAME'];
        }
        $str = 'demopass';
        if (isset($_ENV['ADMIN_PASSWORD'])) {
            $str = $_ENV['ADMIN_PASSWORD'];
        }
        $password = \Hash::make($str);
        $user = User::create([
            'first_name'   => 'Admin',
            'last_name'    => '',
            'email'        => null,
            'user_name'    => $username,
            'password'     => $password,
            'assign_group' => 1,
            'primary_dpt'  => 1,
            'active'       => 1,
            'role'         => 'admin',
        ]);
        // checking if the user have been created
    }
}
