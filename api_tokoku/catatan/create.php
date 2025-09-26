<?php
require_once '../config/database.php';

// Cek apakah metode request adalah POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Ambil data teks dari $_POST
    $judul = isset($_POST['judul']) ? $_POST['judul'] : '';
    $isi_catatan = isset($_POST['isi_catatan']) ? $_POST['isi_catatan'] : '';
    $latitude = isset($_POST['latitude']) ? $_POST['latitude'] : 0.0;
    $longitude = isset($_POST['longitude']) ? $_POST['longitude'] : 0.0;
    $alamat = isset($_POST['alamat' ]) ? $_POST['alamat'] : '';
    $nama_gambar = null;

    // Cek apakah ada file gambar yang diunggah
    if (isset($_FILES['gambar']) && $_FILES['gambar']['error'] == 0) {
        $target_dir = "../uploads/";
        $nama_gambar = time() . '_' . basename($_FILES["gambar"]["name"]);
        $target_file = $target_dir . $nama_gambar;

        if (move_uploaded_file($_FILES["gambar"]["tmp_name"], $target_file)) {
            // File berhasil diunggah
        } else {
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Gagal mengunggah gambar.']);
            exit();
        }
    }

    // Validasi data teks
    if (!empty($judul) && !empty($isi_catatan)) {
        // PERBAIKAN 1: Jumlah placeholder (?) harus 6, sesuai jumlah kolom
        $query = "INSERT INTO catatan (judul, isi_catatan, latitude, longitude, gambar, alamat) VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = $koneksi->prepare($query);

        // PERBAIKAN 2: Tipe data harus 6 karakter ("ssddss") dan variabel harus 6
        $stmt->bind_param("ssddss", $judul, $isi_catatan, $latitude, $longitude, $nama_gambar, $alamat);

        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(['status' => 'success', 'message' => 'Catatan berhasil ditambahkan.']);
        } else {
            http_response_code(500);
            // Tambahkan detail error untuk debugging
            echo json_encode(['status' => 'error', 'message' => 'Gagal menyimpan catatan ke database.', 'db_error' => $stmt->error]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Data tidak lengkap.']);
    }

} else {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Metode tidak diizinkan.']);
}
?>