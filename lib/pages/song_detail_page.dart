import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SongDetailPage extends StatefulWidget {
  final String songId;

  const SongDetailPage({super.key, required this.songId});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  Map<String, dynamic>? song;
  bool isLoading = true;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    fetchSongDetail();
  }

  @override
  void dispose() {
    _youtubeController.pause();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> fetchSongDetail() async {
    final response = await http.get(
      Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song/${widget.songId}'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success']) {
        final data = json['data'];
        final videoId = YoutubePlayer.convertUrlToId(data['source'] ?? '');

        setState(() {
          song = data;
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId ?? '',
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song?['title'] ?? 'Detail Lagu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : song == null
              ? const Center(child: Text('Lagu tidak ditemukan'))
              : YoutubePlayerBuilder(
                  player: YoutubePlayer(controller: _youtubeController),
                  builder: (context, player) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Player
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: player,
                        ),
                        const SizedBox(height: 16),

                        // Deskripsi
                        Text(
                          song!['title'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(song!['artist'], style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),
                        Text(song!['description'] ?? ''),

                        const SizedBox(height: 24),

                        const Text('Komentar:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        Expanded(
                          child: ListView.builder(
                            itemCount: song!['comments'].length,
                            itemBuilder: (context, index) {
                              final comment = song!['comments'][index];
                              return ListTile(
                                title: Text(comment['creator']),
                                subtitle: Text(comment['comment_text']),
                                trailing: Text(comment['createdAt'].split(' ').first),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
