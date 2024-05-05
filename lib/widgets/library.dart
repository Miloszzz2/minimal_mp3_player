import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minimal_mp3_player/structs/playlist.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<Playlist> playlists = [
  Playlist(title: 'Playlist 1', description: 'Description for Playlist 1'),
  Playlist(title: 'Playlist 2', description: 'Description for Playlist 2'),
  Playlist(title: 'Playlist 3', description: 'Description for Playlist 3'),
];

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LibraryMainScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'playlist/:playlistId',
          builder: (BuildContext context, GoRouterState state) =>
              PlaylistScreen(id: state.pathParameters["playlistId"]),
        ),
      ],
    ),
  ],
);

/// The main app.
class Library extends StatelessWidget {
  /// Constructs a [Library]
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      routerConfig: _router,
    );
  }
}

class LibraryMainScreen extends StatefulWidget {
  const LibraryMainScreen({super.key});

  @override
  State<LibraryMainScreen> createState() => _LibraryMainScreenState();
}

class _LibraryMainScreenState extends State<LibraryMainScreen> {
  final TextEditingController _playlistNameController = TextEditingController();
  final _playlists = Supabase.instance.client.from('playlists').select();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Flex(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            const Text(
              " Your library",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder(
                  future: _playlists,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final playlists = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: playlists.length,
                      itemBuilder: ((context, index) {
                        return GestureDetector(
                          onTap: () {
                            context.go("/playlist/${playlists[index]["id"]}");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(255, 44, 44, 44)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  playlists[index]["name"],
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  }),
            ),
          ],
        ),
        Positioned(
          bottom: 15,
          right: 0,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            onPressed: () {
              showShadDialog(
                context: context,
                builder: (context) => ShadDialog(
                  padding: const EdgeInsets.all(25),
                  removeBorderRadiusWhenTiny: false,
                  radius: const BorderRadius.all(Radius.circular(10)),
                  expandActionsWhenTiny: false,
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 30),
                  titleTextAlign: TextAlign.left,
                  title: const Text(
                    'Add playlist',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Container(
                    width: 375,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShadInput(
                          controller: _playlistNameController,
                          placeholder: const Text("Playlist name"),
                        )
                      ],
                    ),
                  ),
                  actions: [
                    ShadButton(
                      text: const Text('Save changes'),
                      onPressed: () async {
                        await Supabase.instance.client
                            .from("playlists")
                            .insert({'name': _playlistNameController.text});
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

/// The details screen
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
  final _player = AudioPlayer();
  @override
  void dispose() {
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

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
                          final String url = Supabase.instance.client.storage
                              .from("songs")
                              .getPublicUrl(
                                  "public/${song["nameWithoutSpecialChars"]}.mp3");
                          debugPrint(song["nameWithoutSpecialChars"]);
                          // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
                          await _player
                              .setAudioSource(AudioSource.uri(Uri.parse(url)));
                        } on PlayerException catch (e) {
                          debugPrint("Error loading audio source: $e");
                        }
                        await _player.play();
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
