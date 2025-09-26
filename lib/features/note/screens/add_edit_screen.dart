// lib/features/note/screens/add_edit_screen.dart
import 'dart:io';
import 'package:tokoku/features/note/models/note_model.dart';
import 'package:tokoku/features/note/services/note_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddEditScreen extends StatefulWidget {
  final Note? note;
  const AddEditScreen({super.key, this.note});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _addressController = TextEditingController();
  final NoteService _noteService = NoteService();
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  double? _currentLatitude;
  double? _currentLongitude;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.note!.judul;
      _contentController.text = widget.note!.isiCatatan;
      _addressController.text = widget.note!.alamat ?? '';
      _currentLatitude = widget.note!.latitude;
      _currentLongitude = widget.note!.longitude;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw ('Izin lokasi ditolak oleh pengguna.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}";
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          _addressController.text = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mengambil gambar: $e")));
      }
    }
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final note = Note(
        id: _isEditing ? widget.note!.id : 0,
        judul: _titleController.text,
        isiCatatan: _contentController.text,
        latitude: _currentLatitude ?? 0.0,
        longitude: _currentLongitude ?? 0.0,
        alamat: _addressController.text,
        waktuDibuat: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        // Edit → tanpa gambar
        success = await _noteService.updateNote(note);
      } else {
        // Tambah → bisa menyertakan gambar
        success = await _noteService.addNote(
          note,
          imageFile: _imageFile != null ? File(_imageFile!.path) : null,
        );
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Catatan berhasil disimpan' : 'Gagal menyimpan catatan',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(_imageFile!.path),
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
      );
    }
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text(
              'Gambar akan tampil di sini',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Isi catatan tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Lokasi',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.gps_fixed),
                    onPressed: _getCurrentLocation,
                    tooltip: 'Dapatkan Lokasi Saat Ini',
                  ),
                ),
                maxLines: 2,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              // **Hanya tampilkan gambar jika tambah catatan**
              if (!_isEditing) ...[
                _buildImagePreview(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _saveNote,
                    child: const Text('Simpan Catatan'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
