<?php
require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"));

    if (!empty($data->id)) {
        $id_catatan = $data->id;
        $nama_gambar_lama = null;

        // Langkah 1: Ambil nama file gambar dari database SEBELUM menghapus record
        $query_select = "SELECT gambar FROM catatan WHERE id = ?";
        $stmt_select = $koneksi->prepare($query_select);
        $stmt_select->bind_param("i", $id_catatan);
        $stmt_select->execute();
        $result = $stmt_select->get_result();
        if ($row = $result->fetch_assoc()) {
            $nama_gambar_lama = $row['gambar'];
        }
        $stmt_select->close();

        // Langkah 2: Hapus record dari database
        $query_delete = "DELETE FROM catatan WHERE id = ?";
        $stmt_delete = $koneksi->prepare($query_delete);
        $stmt_delete->bind_param("i", $id_catatan);

        if ($stmt_delete->execute()) {
            if ($stmt_delete->affected_rows > 0) {
                // Langkah 3: Jika record berhasil dihapus DAN ada file gambar lama, hapus file dari server
                if ($nama_gambar_lama) {
                    $file_path = '../uploads/' . $nama_gambar_lama;
                    if (file_exists($file_path)) {
                        unlink($file_path); // Fungsi untuk menghapus file
                    }
                }
                http_response_code(200);
                echo json_encode(['status' => 'success', 'message' => 'Catatan berhasil dihapus.']);
            } else {
                http_response_code(404);
                echo json_encode(['status' => 'error', 'message' => 'Catatan tidak ditemukan.']);
            }
        } else {
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Gagal menghapus catatan.']);
        }
        $stmt_delete->close();
    } else {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'ID catatan tidak boleh kosong.']);
    }
} else {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Metode tidak diizinkan.']);
}
?>