import 'package:flutter/material.dart';
import 'package:vlc_player_x/vlc_player_x.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    VlcPlayerController controller = VlcPlayerController.network('https://media.w3.org/2010/05/sintel/trailer.mp4');
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body:
          VlcPlayerX(
            controller: controller,
            aspectRatio: 16 / 9,
            onClose: () {
              debugPrint("Close");
            },
          ),
      ),
    );
  }
}