import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minimal_mp3_player/structs/playlist.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

/// The home screen
class LibraryMainScreen extends StatelessWidget {
  const LibraryMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Flex(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      direction: Axis.vertical,
      children: [
        Text(
          " Your library",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
            child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 10.0, // Spacing between columns
            mainAxisSpacing: 10.0, // Spacing between rows
          ),
          itemCount: playlists.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                context.go("/playlist/$index");
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
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
          },
        ))
      ],
    ));
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
