import 'package:flutter/material.dart';

// define the starting point of the Flutter app
void main() {
  runApp(MaterialApp(
      home: Scaffold(
    backgroundColor: Colors.blueGrey,
    appBar: AppBar(
      title: const Text(
        'I Am Rich',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueGrey[900],
    ),
    body: Stack(
      children: [
        // Image de fond
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/images.jpeg'),
              // NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnmP8QAfBUSPivSO_mMXgc400IN0hpGFaPfA&s'), // Chemin de l'image
              fit: BoxFit.cover, // Ajuste l'image pour couvrir tout l'écran
            ),
          ),
        ),
        // Contenu principal de la page
        Center(
          child: Text(
            'Hello World!',
            style: TextStyle(color: Colors.blue, fontSize: 50),
          ),
        ),
      ],
    ),
  )));
}
