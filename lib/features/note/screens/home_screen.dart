// lib/features/note/screens/home_screen.dart

import 'package:tokoku/features/note/models/note_model.dart';
import 'package:tokoku/features/note/screens/add_edit_screen.dart';
import 'package:tokoku/features/note/services/note_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _futureNotes;
  final NoteService _noteService = NoteService();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _futureNotes = _noteService.getNotes();
    });
  }

  void _navigateToAddEditScreen([Note? note]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => AddEditScreen(note: note)),
        )
        .then((_) => _loadNotes());
  }

  void _deleteNote(int id) async {
    bool deleted = await _noteService.deleteNote(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deleted ? 'Catatan berhasil dihapus' : 'Gagal menghapus catatan',
          ),
          backgroundColor: deleted ? Colors.green : Colors.red,
        ),
      );
      if (deleted) {
        _loadNotes();
      }
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteNote(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toko Belanjaku')),
      body: FutureBuilder<List<Note>>(
        future: _futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }

          List<Note> notes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(
              8.0,
            ), // Beri sedikit padding pada list
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              // <-- AWAL PERUBAHAN: Menggunakan Card dengan Column untuk layout baru -->
              return Card(
                clipBehavior:
                    Clip.antiAlias, // Penting agar gambar mengikuti bentuk Card
                child: InkWell(
                  // Membuat seluruh Card bisa di-tap
                  onTap: () => _navigateToAddEditScreen(note),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Bagian Gambar (hanya tampil jika ada gambar)
                      if (note.gambar != null)
                        Image.network(
                          note.gambar!,
                          width: double.infinity, // Lebar penuh
                          height: 180, // Tinggi gambar
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),

                      // 2. Bagian Konten (Teks dan Tombol)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Baris untuk Judul dan Tombol Hapus
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.judul,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () =>
                                      _showDeleteConfirmation(note.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    note.alamat ?? 'Lokasi tidak tersedia',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[700]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Isi Catatan
                            Text(
                              note.isiCatatan,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3, // Batasi 3 baris
                              overflow: TextOverflow
                                  .ellipsis, // Tampilkan '...' jika lebih
                            ),

                            // Tanggal Dibuat
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                DateFormat(
                                  'dd MMMM yyyy, HH:mm',
                                ).format(note.waktuDibuat),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
              // <-- AKHIR PERUBAHAN -->
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
