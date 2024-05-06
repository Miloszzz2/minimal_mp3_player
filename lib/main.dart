import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:minimal_mp3_player/player/common.dart';
import 'package:minimal_mp3_player/player/player.dart';
import 'package:minimal_mp3_player/widgets/download.dart';
import 'package:minimal_mp3_player/widgets/library.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  String supabaseUrl = dotenv.get('SUPABASE_URL');
  String supabaseAnonKey = dotenv.get('SUPABASE_API_KEY');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      home: const MainPage(),
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.dark(),
        textTheme: ShadTextTheme(
          colorScheme: const ShadZincColorScheme.light(),
          family: 'Geist',
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;

  Stream<PositionData> _positionDataStream() =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        surfaceTintColor: const Color.fromARGB(255, 0, 0, 0),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.library_music),
            icon: Icon(Icons.library_music_outlined),
            label: 'Library',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.download),
            icon: Icon(Icons.download_outlined),
            label: 'Download',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: [
                  const Library(),
                  const Download(),
                  const Center(
                    child: Text("Settings"),
                  )
                ][currentPageIndex]),
          ),
          Container(
            decoration: const BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(
                      color: Color.fromARGB(255, 37, 37, 37), width: 1.0),
                )),
            height: 137, // Adjust the height as needed
            // Customize color
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder<SequenceState?>(
                  stream: player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.sequence.isEmpty ?? true) {
                      return const SizedBox(
                        child: Text(
                          "No current track",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    final metadata = state!.currentSource!.tag as MediaItem;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          metadata.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<SequenceState?>(
                      stream: player.sequenceStateStream,
                      builder: (context, snapshot) => IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed:
                            player.hasPrevious ? player.seekToPrevious : null,
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 20.0,
                            height: 20.0,
                            child: const CircularProgressIndicator(),
                          );
                        } else if (playing != true) {
                          return IconButton(
                            icon: const Icon(Icons.play_arrow),
                            iconSize: 20.0,
                            onPressed: player.play,
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return IconButton(
                            icon: const Icon(Icons.pause),
                            iconSize: 20.0,
                            onPressed: player.pause,
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(Icons.replay),
                            iconSize: 20.0,
                            onPressed: () => player.seek(Duration.zero,
                                index: player.effectiveIndices!.first),
                          );
                        }
                      },
                    ),
                    StreamBuilder<SequenceState?>(
                      stream: player.sequenceStateStream,
                      builder: (context, snapshot) => IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: player.hasNext ? player.seekToNext : null,
                      ),
                    ),
                  ],
                ),
                StreamBuilder<PositionData>(
                  stream: _positionDataStream(),
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return SeekBar(
                      duration: positionData?.duration ?? Duration.zero,
                      position: positionData?.position ?? Duration.zero,
                      bufferedPosition:
                          positionData?.bufferedPosition ?? Duration.zero,
                      onChangeEnd: player.seek,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
