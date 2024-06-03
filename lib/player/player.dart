import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AppStateStore with ChangeNotifier, DiagnosticableTreeMixin {
  final AudioPlayer audioPlayer = AudioPlayer();
  final ConcatenatingAudioSource playlist =
      ConcatenatingAudioSource(children: []);
}
