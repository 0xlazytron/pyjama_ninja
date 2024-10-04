import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';  // Import for setting orientation
import 'package:pyjama_ninja/pyjama_ninja.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the device orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Flame.device.fullScreen();  // Make the game full screen

  runApp(
    const MaterialApp(
      home: Scaffold(
        body: FruitNinjaGameScreen(),
      ),
    ),
  );
}

class FruitNinjaGameScreen extends StatelessWidget {
  const FruitNinjaGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(
          game: PyjamaNinja(),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: Icon(Icons.pause, color: Colors.white),
            onPressed: () {
              showPauseMenu(context);
            },
          ),
        ),
      ],
    );
  }

  void showPauseMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pause Menu"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Resume"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement exit logic here if necessary
              },
              child: Text("Exit"),
            ),
          ],
        );
      },
    );
  }
}
