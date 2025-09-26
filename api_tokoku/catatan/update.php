<?php
require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Ambil data teks dari $_POST
    $id = isset($_POST['id']) ? intval($_POST['id']) : 0;
    $judul = isset($_POST['judul']) ? $_POST['judul'] : '';
    $isi_catatan = isset($_POST['isi_catatan']) ? $_POST['isi_catatan'] : '';
    $latitude = isset($_POST['latitude']) ? $_POST['latitude'] : 0.0;
    $longitude = isset($_POST['longitude']) ? $_POST['longitude'] : 0.0;
    $alamat = isset($_POST['alamat']) ? $_POST['alamat'] : '';

    if (empty($id) || empty($judul) || empty($isi_catatan)) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Data tidak lengkap.']);
        exit();
    }

    $nama_gambar_lama = null;
    $stmt_select = $koneksi->prepare("SELECT gambar FROM catatan WHERE id = ?");
    $stmt_select->bind_param("i", $id);
    $stmt_select->execute();
    $result = $stmt_select->get_result();
    if ($row = $result->fetch_assoc()) {
        $nama_gambar_lama = $row['gambar'];
    }
    $stmt_select->close();

    $nama_gambar_baru = $nama_gambar_lama;

    if (isset($_FILES['gambar']) && $_FILES['gambar']['error'] == 0) {
        $target_dir = "../uploads/";
        $nama_gambar_baru = time() . '_' . basename($_FILES["gambar"]["name"]);
        $target_file = $target_dir . $nama_gambar_baru;

        if (move_uploaded_file($_FILES["gambar"]["tmp_name"], $target_file)) {
            if ($nama_gambar_lama && file_exists($target_dir . $nama_gambar_lama)) {
                unlink($target_dir . $nama_gambar_lama);
            }
        } else {
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Gagal mengunggah gambar baru.']);
            exit();
        }
    }

    $query = "UPDATE catatan SET judul = ?, isi_catatan = ?, latitude = ?, longitude = ?, gambar = ?, alamat = ? WHERE id = ?";
    $stmt_update = $koneksi->prepare($query);
    $stmt_update->bind_param("ssddssi", $judul, $isi_catatan, $latitude, $longitude, $nama_gambar_baru, $alamat, $id);

    if ($stmt_update->execute()) {
        if ($stmt_update->affected_rows > 0) {
            http_response_code(200);
            echo json_encode(['status' => 'success', 'message' => 'Catatan berhasil diperbarui.']);
        } else {
            http_response_code(200);
            echo json_encode(['status' => 'success', 'message' => 'Tidak ada data yang berubah.']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Gagal memperbarui catatan.', 'db_error' => $stmt_update->error]);
    }
    $stmt_update->close();

} else {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Metode tidak diizinkan.']);
}
?>