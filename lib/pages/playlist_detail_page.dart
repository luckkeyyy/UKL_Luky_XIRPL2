import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'song_detail_page.dart'; // Pastikan file ini ada dan benar

class PlaylistDetailPage extends StatefulWidget {
  final Map playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  List<dynamic> songs = [];
  List<dynamic> filteredSongs = [];
  bool isLoading = true;
  String playlistName = "";
  String searchQuery = "";
  Set<String> likedSongs = {};

  @override
  void initState() {
    super.initState();
    fetchPlaylistDetail();
  }

  Future<void> fetchPlaylistDetail() async {
    try {
      final uuid = widget.playlist['uuid'];

      final httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      final ioClient = IOClient(httpClient);

      final response = await ioClient.get(
        Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song-list/$uuid'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          playlistName = widget.playlist['playlist_name'];
          songs = data['data'];
          filteredSongs = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat detail playlist');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredSongs = songs.where((song) {
        return song['title'].toLowerCase().contains(searchQuery) ||
            song['artist'].toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  void toggleLike(String uuid) {
    setState(() {
      if (likedSongs.contains(uuid)) {
        likedSongs.remove(uuid);
      } else {
        likedSongs.add(uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari lagu...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: handleSearch,
                  ),
                ),
                Expanded(
                  child: filteredSongs.isEmpty
                      ? const Center(child: Text("Tidak ada lagu ditemukan"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = filteredSongs[index];
                            final uuid = song['uuid'];
                            final image = song['thumbnail'];
                            final coverUrl =
                                'https://learn.smktelkom-mlg.sch.id/ukl2/thumbnail/${Uri.encodeComponent(image)}';
                            final isLiked = likedSongs.contains(uuid);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SongDetailPage(songId: uuid),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              coverUrl,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.image_not_supported, size: 48),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  song['title'],
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  song['artist'],
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  song['description'] ?? '',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => toggleLike(uuid),
                                            child: Icon(
                                              Icons.favorite,
                                              color: isLiked ? Colors.amber : Colors.grey,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text('${song['likes']} suka'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
