import 'package:flutter/material.dart';
import 'package:minimal_mp3_player/utils/download_mp3.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Download extends StatefulWidget {
  const Download({super.key});

  @override
  State<Download> createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  final TextEditingController _urlTextController = TextEditingController();
  var playlistId = 0;
  final _playlists = Supabase.instance.client.from('playlists').select();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _urlTextController.dispose();
    super.dispose();
  }

  List<Widget> getPlaylistsWidgets(
      ShadThemeData theme, List<Map<String, dynamic>> playlists) {
    final widgets = <Widget>[];
    for (final playlist in playlists) {
      widgets.add(ShadOption(
          value: playlist["id"].toString(), child: Text(playlist["name"])));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Flex(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          direction: Axis.vertical,
          children: [
            const Text(
              " Download",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: _playlists,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final playlists = snapshot.data!;

                  return ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 280),
                      child: ShadSelect<String>(
                        placeholder: const Text('Select a playlist'),
                        options: getPlaylistsWidgets(
                            ShadTheme.of(context), playlists),
                        selectedOptionBuilder: (context, value) {
                          final playlist = playlists.firstWhere((element) =>
                              element["id"].toString() == value)["name"];

                          return Text(playlist!);
                        },
                        onChanged: (value) {
                          playlistId = int.parse(value);
                          debugPrint(playlistId.toString());
                        },
                      ));
                }),
            ShadInput(
              controller: _urlTextController,
              placeholder: const Text("Url to youtube"),
            ),
            ShadButton(
              text: const Text("Download"),
              onPressed: () {
                debugPrint(_urlTextController.text);
                if (playlistId != 0 && _urlTextController.text != "") {
                  // Show "Downloading..." message
                  ShadToaster.of(context).show(
                    const ShadToast(
                      duration: Duration(seconds: 1200),
                      title: Text('Downloading...'),
                    ),
                  );

                  // Call the download function
                  downloadMp3FileFromYoutube(
                          _urlTextController.text, playlistId)
                      .then((result) {
                    // Hide the message after download completes
                    ShadToaster.of(context).hide();
                    ShadToaster.of(context).show(
                      const ShadToast(
                        duration: Duration(seconds: 2),
                        title: Text('Finished!!'),
                      ),
                    );
                  });
                }
              },
            )
          ],
        ),
      ],
    );
  }
}
