import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // untuk MediaType
import 'package:image_picker/image_picker.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({super.key});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _descController = TextEditingController();
  final _sourceController = TextEditingController();

  File? _thumbnail;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final fileSize = await file.length();
      final ext = picked.path.split('.').last.toLowerCase();

      if (fileSize > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File terlalu besar (maksimal 2MB).")),
        );
        return;
      }

      if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hanya file JPG, JPEG, atau PNG yang diperbolehkan.")),
        );
        return;
      }

      setState(() => _thumbnail = file);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _thumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data dan thumbnail")),
      );
      return;
    }

    setState(() => _isUploading = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song'),
    );

    request.fields['title'] = _titleController.text;
    request.fields['artist'] = _artistController.text;
    request.fields['description'] = _descController.text;
    request.fields['source'] = _sourceController.text;

    final ext = _thumbnail!.path.split('.').last.toLowerCase();
    MediaType contentType;

    if (ext == 'jpg' || ext == 'jpeg') {
      contentType = MediaType('image', 'jpeg');
    } else if (ext == 'png') {
      contentType = MediaType('image', 'png');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tipe file tidak didukung. Gunakan JPG atau PNG.")),
      );
      setState(() => _isUploading = false);
      return;
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'thumbnail',
        _thumbnail!.path,
        contentType: contentType,
      ),
    );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = jsonDecode(responseBody);
      print('Response status: ${response.statusCode}');
      print('Response body: $decoded');

      if (response.statusCode == 201 && decoded['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lagu berhasil ditambahkan!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan lagu: ${decoded['message']}")),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Lagu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
                validator: (value) => value!.isEmpty ? 'Artist wajib diisi' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(labelText: 'URL YouTube'),
                validator: (value) => value!.isEmpty ? 'URL wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _thumbnail == null
                  ? const Text("Thumbnail belum dipilih.")
                  : Image.file(_thumbnail!, height: 150),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Thumbnail'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _submitForm,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
