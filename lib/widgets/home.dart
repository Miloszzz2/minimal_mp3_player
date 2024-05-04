import 'package:flutter/material.dart';
import 'package:minimal_mp3_player/components/playlist_home_component.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTabChanged;

  const HomePage({Key? key, required this.onTabChanged}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client.from('playlists').select();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Flex(
      direction: Axis.vertical,
      children: [
        const Text(
          "Welcome in MinimalistPlayer",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
            child: FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final playlists = snapshot.data!;
                  debugPrint(playlists.length.toString());
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
                      final playlist = playlists[index];
                      return PlaylistContainer(
                        onTabChanged: widget.onTabChanged,
                        text: playlist['name'],
                      );
                    }),
                  );
                }))
      ],
    ));
  }
}
