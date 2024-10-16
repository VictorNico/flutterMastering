import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final player = AudioPlayer(); // Créez une instance de AudioPlayer
  var colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple
  ];
  void _playSound(note) {
    setState(() {
      // generateWordPairs().take(5).forEach(print);
      player.setAsset('assets/note$note.wav'); // Chargez le fichier audio
      player.play();
    });
  }

  Widget _generateButton(note) {
    return Expanded(
      child: FilledButton(
        onPressed: () {
          _playSound(note);
        },
        child: null,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colors[note - 1]),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Coins carrés
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 1; i < 8; i++) _generateButton(i)

          // ElevatedButton(
          //   style: ButtonStyle(),
          //   onPressed: () => {print(0)},
          //   child: null,
          // )
          // Expanded(
          //   child: FilledButton(
          //     onPressed: () {
          //       _play_sound(1);
          //     },
          //     child: null,
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.red),
          //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //         const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero, // Coins carrés
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: FilledButton(
          //     onPressed: () {
          //       _play_sound(2);
          //     },
          //     child: null,
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.orange),
          //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //         const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero, // Coins carrés
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: FilledButton(
          //     onPressed: () {
          //       _play_sound(3);
          //     },
          //     child: null,
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.yellow),
          //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //         const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero, // Coins carrés
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: FilledButton(
          //     onPressed: () {
          //       _play_sound(4);
          //     },
          //     child: null,
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.green),
          //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //         const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero, // Coins carrés
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: FilledButton(
          //     onPressed: () {
          //       _play_sound(5);
          //     },
          //     child: null,
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.teal),
          //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //         const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero, // Coins carrés
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: FilledButton(
          //     onPressed: () {
          //       _play_sound(6);
          //     },
          //     child: null,
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
          //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //         const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero, // Coins carrés
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: FilledButton(
          //     onPressed: () {
          //       _play_sound(7);
          //     },
          //     child: null,
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.purple),
          //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //         const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero, // Coins carrés
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
