<?php
// Set header untuk memberitahu client bahwa responsnya adalah JSON
header("Content-Type: application/json; charset=UTF-8");
// Set header untuk mengizinkan akses dari mana saja (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Detail koneksi database
$host = "localhost";
$db_name = "db_tokoku";
$username = "root"; 
$password = "";     

// Buat koneksi
$koneksi = new mysqli($host, $username, $password, $db_name);

// Cek koneksi
if ($koneksi->connect_error) {
    die("Koneksi database gagal: " . $koneksi->connect_error);
}
?>