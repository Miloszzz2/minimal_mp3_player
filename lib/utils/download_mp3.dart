import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

String removeNonLetters(String key) {
  RegExp regex = RegExp(r'[^\w\s]');
  return key.replaceAll(regex, '');
}

Future<File> _localFile(String url) async {
  final yt = YoutubeExplode();
  var video = await yt.videos.get(url);
  var title = video.title;
  var author = video.author;
  final path = await _localPath;
  return File('$path/$author-$title.mp3');
}

Future<void> downloadMp3FileFromYoutube(String url, int playlistId) async {
  final yt = YoutubeExplode();

  var video = await yt.videos.get(url);
  var title = video.title;
  var author = video.author;
  // You can provide either a video ID or URL as String or an instance of `VideoId`.
  var manifest = await yt.videos.streamsClient
      .getManifest(url); // Returns a Video instance.
  var streamInfo = manifest.audioOnly.withHighestBitrate();
  // Get the actual stream
  var stream = yt.videos.streamsClient.get(streamInfo);

  // Open a file for writing.
  var file = await _localFile(url);
  var fileStream = file.openWrite();

  // Pipe all the content of the stream into the file.
  await stream.pipe(fileStream);
  var name = removeNonLetters(title);
  // Close the file.
  await fileStream.flush();
  await fileStream.close();

  await Supabase.instance.client.storage.from('songs').upload(
        'public/$name.mp3',
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

  String publicUrl = Supabase.instance.client.storage
      .from('songs')
      .getPublicUrl('public/$name.mp3');

  await Supabase.instance.client.from("songs").upsert({
    "name": title,
    "author": author,
    "playlistId": playlistId,
    "nameWithoutSpecialChars": name,
    "publicUrl": publicUrl
  }, onConflict: 'name, playlistId');

  await file.delete();
  yt.close();
}
