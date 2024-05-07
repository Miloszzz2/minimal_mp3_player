library player;

import 'package:just_audio/just_audio.dart';

final AudioPlayer player = AudioPlayer();
final ConcatenatingAudioSource playlist =
    ConcatenatingAudioSource(children: []);
