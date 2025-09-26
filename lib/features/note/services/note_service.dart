import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tokoku/core/constants/api_constants.dart';
import 'package:tokoku/features/note/models/note_model.dart';

class NoteService {
  final String _baseUrl = ApiConstants.notesUrl;

  Future<List<Note>> getNotes() async {
    final response = await http.get(Uri.parse('$_baseUrl/read.php'));

    if (response.statusCode == 200) {
      // Handle jika body kosong (respons '[]')
      if (response.body.isNotEmpty) {
        Iterable jsonResponse = json.decode(response.body);
        return jsonResponse.map((note) => Note.fromJson(note)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<bool> addNote(Note note, {File? imageFile}) async {
    var uri = Uri.parse('$_baseUrl/create.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['judul'] = note.judul;
    request.fields['isi_catatan'] = note.isiCatatan;
    request.fields['latitude'] = note.latitude.toString();
    request.fields['longitude'] = note.longitude.toString();
    request.fields['alamat'] = note.alamat ?? '';

    if (imageFile != null) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'gambar',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      return true;
    } else {
      final responseBody = await response.stream.bytesToString();
      print("Gagal tambah data, status code: ${response.statusCode}");
      print("Response dari server: $responseBody");
      return false;
    }
  }

  // <-- AWAL PERBAIKAN FUNGSI UPDATE -->
  Future<bool> updateNote(Note note, {File? imageFile}) async {
    var uri = Uri.parse('$_baseUrl/update.php');
    var request = http.MultipartRequest('POST', uri);

    // Kirim semua data sebagai fields
    request.fields['id'] = note.id.toString();
    request.fields['judul'] = note.judul;
    request.fields['isi_catatan'] = note.isiCatatan;
    request.fields['latitude'] = note.latitude.toString();
    request.fields['longitude'] = note.longitude.toString();
    request.fields['alamat'] = note.alamat ?? '';

    // NOTE: Logika untuk mengganti gambar saat update belum diimplementasikan sepenuhnya.
    // Kode ini hanya memastikan data teks terkirim dengan format yang benar.
    if (imageFile != null) {
      // Logika untuk menambahkan file gambar baru saat update bisa ditambahkan di sini
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      // <-- KODE UNTUK MENAMPILKAN ERROR DI DEBUG CONSOLE -->
      final responseBody = await response.stream.bytesToString();
      print("Gagal update, status code: ${response.statusCode}");
      print("Response dari server: $responseBody");
      // <--------------------------------------------------->
      return false;
    }
  }
  // <-- AKHIR PERBAIKAN FUNGSI UPDATE -->

  Future<bool> deleteNote(int id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/delete.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'id': id}),
    );
    return response.statusCode == 200;
  }
}
