import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'playlist_detail_page.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<dynamic> playlists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  HttpClient _getHttpClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return httpClient;
  }

  Future<void> fetchPlaylists() async {
    try {
      final ioClient = IOClient(_getHttpClient());
      final response = await ioClient.get(
        Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl2/playlists'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          setState(() {
            playlists = json['data'];
            isLoading = false;
          });
        } else {
          throw Exception("Data tidak valid");
        }
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Playlists'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : playlists.isEmpty
              ? const Center(child: Text("Tidak ada playlist ditemukan"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final title = playlist['playlist_name'] ?? 'Tanpa Nama';
                    final songCount = playlist['song_count'] ?? 0;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.queue_music, size: 40),
                        title: Text(title),
                        subtitle: Text('$songCount lagu'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaylistDetailPage(playlist: playlist),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
