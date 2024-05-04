import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
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
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10.0, // Spacing between columns
                      mainAxisSpacing: 10.0, // Spacing between rows
                    ),
                    itemCount: playlists
                        .length, // Add one for the "Add Playlist" button
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          context.go("/playlist/$index");
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
                                playlists[index].title,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                playlists[index].description,
                                style: const TextStyle(fontSize: 14.0),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
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
      ),
    );
  }
}

/// The details screen
class PlaylistScreen extends StatelessWidget {
  /// Constructs a [PlaylistScreen]
  final String? id;
  const PlaylistScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => context.go('/'),
        child: Text(id ?? "Id"),
      ),
    );
  }
}
