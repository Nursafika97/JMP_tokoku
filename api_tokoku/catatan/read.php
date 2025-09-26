<?php
require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Cek apakah ada parameter 'id' di URL
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;

    if ($id > 0) {
        // Ambil satu catatan berdasarkan ID
        // PERUBAHAN 1: Tambahkan 'gambar' di query SELECT
        $query = "SELECT id, judul, isi_catatan, latitude, longitude, waktu_dibuat, gambar, alamat  FROM catatan WHERE id = ?";
        $stmt = $koneksi->prepare($query);
        $stmt->bind_param("i", $id);
    } else {
        // Ambil semua catatan
        // PERUBAHAN 1: Tambahkan 'gambar' di query SELECT
        $query = "SELECT id, judul, isi_catatan, latitude, longitude, waktu_dibuat, gambar, alamat  FROM catatan ORDER BY waktu_dibuat DESC";
        $stmt = $koneksi->prepare($query);
    }

    $stmt->execute();
    $result = $stmt->get_result();
    $catatan_arr = [];

    while ($row = $result->fetch_assoc()) {
        $catatan_item = [
            'id' => $row['id'],
            'judul' => $row['judul'],
            'isi_catatan' => $row['isi_catatan'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'waktu_dibuat' => $row['waktu_dibuat'],
            'gambar' => $row['gambar'],
            'alamat' => $row['alamat']
        ];
        array_push($catatan_arr, $catatan_item);
    }

    // Selalu kirim status 200 OK karena query berhasil dijalankan.
    http_response_code(200);
    echo json_encode($catatan_arr);

} else {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['status' => 'error', 'message' => 'Metode tidak diizinkan.']);
}
?>