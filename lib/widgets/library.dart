import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minimal_mp3_player/components/playlist.dart';
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
      debugShowCheckedModeBanner: false,
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
