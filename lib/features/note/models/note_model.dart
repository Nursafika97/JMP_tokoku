import 'package:tokoku/core/constants/api_constants.dart';

class Note {
  final int id;
  final String judul;
  final String isiCatatan;
  final double latitude;
  final double longitude;
  final DateTime waktuDibuat;
  final String? gambar;
  final String? alamat;

  Note({
    required this.id,
    required this.judul,
    required this.isiCatatan,
    required this.latitude,
    required this.longitude,
    required this.waktuDibuat,
    this.gambar,
    this.alamat,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: int.parse(json['id'].toString()),
      judul: json['judul'],
      isiCatatan: json['isi_catatan'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      waktuDibuat: DateTime.parse(json['waktu_dibuat']),
      gambar: json['gambar'] != null
          ? '${ApiConstants.baseUrl}/uploads/${json['gambar']}'
          : null,
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi_catatan': isiCatatan,
      'latitude': latitude,
      'longitude': longitude,
      'alamat': alamat,
    };
  }
}
