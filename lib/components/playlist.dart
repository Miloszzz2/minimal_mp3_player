import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:minimal_mp3_player/player/common.dart';
import 'package:minimal_mp3_player/player/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaylistScreen extends StatefulWidget {
  // Corrected constructor declaration
  final String? id;

  const PlaylistScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late String? id;
  late PostgrestFilterBuilder _songs; // Declare _songs here
  late PostgrestFilterBuilder _playlistName;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    if (id != null) {
      _songs = Supabase.instance.client
          .from('songs')
          .select()
          .eq("playlistId", int.parse(widget.id ?? ""));
    }
    _playlistName = Supabase.instance.client
        .from("playlists")
        .select()
        .eq('id', int.parse(widget.id ?? ""));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flex(
          direction: Axis.horizontal,
          children: [
            IconButton(
                onPressed: () {
                  context.go("/");
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                )),
            const SizedBox(
              width: 10,
            ),
            FutureBuilder(
                future: _playlistName,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var playlist = snapshot.data;
                    return Text(
                      playlist[0]['name'],
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return const Text(
                      "Loading...",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    );
                  }
                })
          ],
        ),
        FutureBuilder(
            future: _songs, // Call query() on _songs
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              }
              final songs = snapshot.data!;
              if (songs.length > 0) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  shrinkWrap: true,
                  itemCount: songs.length,
                  itemBuilder: ((BuildContext context, int index) {
                    final song = songs[index];
                    return GestureDetector(
                      onTap: () async {
                        try {
                          List<dynamic> songsToPlaylist = [];
                          for (var i = index; i < songs.length; i++) {
                            songsToPlaylist.add(songs[i]);
                          }

                          List<AudioSource> audioSources = songsToPlaylist
                              .map((song) => AudioSource.uri(
                                  Uri.parse(song["publicUrl"]),
                                  tag: MediaItem(
                                      id: song["id"].toString(),
                                      title: song["name"].toString())))
                              .toList();

                          final playlist = ConcatenatingAudioSource(
                            useLazyPreparation: true,
                            shuffleOrder: DefaultShuffleOrder(),
                            children: audioSources,
                          );

                          debugPrint(songsToPlaylist.toString());

                          await player.setAudioSource(playlist,
                              initialIndex: 0, initialPosition: Duration.zero);
                        } on PlayerException catch (e) {
                          debugPrint("Error loading audio source: $e");
                        }

                        await player.play();
                      },
                      child: ListTile(
                        dense: true,
                        title: Text(
                          "${(index + 1).toString()} . ${song["name"]} - ${song["author"]}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                    );
                  }),
                );
              } else {
                return const Expanded(
                  child: Center(
                      child: Text(
                    "No songs on this playlist",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                );
              }
            }),
      ],
    );
  }
}
