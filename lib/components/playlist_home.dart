import 'package:flutter/material.dart';

class PlaylistContainer extends StatelessWidget {
  final String text;

  const PlaylistContainer({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(7),
      decoration: BoxDecoration(
          border: Border.all(
              width: 1.0, color: const Color.fromARGB(255, 44, 44, 44)),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Center(
          child: Text(
        text,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      )),
    );
  }
}
