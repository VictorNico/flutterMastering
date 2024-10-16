import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dicee Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dicee Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _nber1 = 1;
  int _nber2 = 1;

// Joueur actif (1 ou 2)
  int _currentPlayer = 1;
  int _nbParties = 1;

// Variable pour contrôler la visibilité du tableau de bord
  bool _showScoreboard = false;

// Lancés de chaque joueur
  List<int> _player1Throws = [];
  List<int> _player2Throws = [];

  // bool _blinking = true; // Initialisez _blinking à true
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // _startBlinking(); // Démarrez l'animation de clignotement
  // }
  //
  // void _startBlinking() {
  //   Timer.periodic(const Duration(milliseconds: 1000), (timer) {
  //     setState(() {
  //       _blinking = !_blinking; // Inversez l'état de _blinking
  //     });
  //   });
  // }

// Scores de chaque joueur (nombre de victoires)
  List<int> _player1Score = [];
  List<int> _player2Score = [];
  int _tempval = 0;

// methodes
  void _randomlyGetTwoNumbers() {
    setState(() {
      _nber1 = Random().nextInt(6) + 1;
      _nber2 = Random().nextInt(6) + 1;
      _addThrow(_nber1, _nber2);
      _checkWin();
      if (_currentPlayer == 2) {
        _nbParties++;
      }
      _changePlayer();
    });
  }

  void _changePlayer() {
    _currentPlayer = _currentPlayer == 1 ? 2 : 1;
  }

  void _addThrow(int dice1, int dice2) {
    if (_currentPlayer == 1) {
      _player1Throws.add(dice1);
      _player1Throws.add(dice2);
    } else {
      _player2Throws.add(dice1);
      _player2Throws.add(dice2);
    }
  }

  void _checkWin() {
    if (_currentPlayer == 1) {
      _tempval = _nber1 + _nber2;
    } else {
      //   si oui, comparer les nombres
      if (_nber1 + _nber2 < _tempval) {
        _player1Score.add(1);
        _player2Score.add(0);
      } else if (_nber1 + _nber2 > _tempval) {
        _player2Score.add(1);
        _player1Score.add(0);
      } else {
        _player1Score.add(1);
        _player2Score.add(1);
      }
    }
  }

  int player1ScoreSum() {
    return _player1Score.isEmpty
        ? 0
        : _player1Score.reduce((value, element) => value + element);
  }

  int player2ScoreSum() {
    return _player2Score.isEmpty
        ? 0
        : _player2Score.reduce((value, element) => value + element);
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Félicitations !'),
          content: Text('Joueur $_currentPlayer a gagné !'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer l'alerte
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.games),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon:
                Icon(_showScoreboard ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showScoreboard = !_showScoreboard;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_sharp),
            onPressed: () {
              setState(() {
                _nber1 = 1;
                _nber2 = 1;
                _currentPlayer = 1;
                _nbParties = 1;
                _showScoreboard = false;
                _player1Throws = [];
                _player2Throws = [];
                _player1Score = [];
                _player2Score = [];
                _tempval = 0;
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.teal,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Annoncer le joeur qui doit lancer
              Text(
                'Partie $_nbParties, Au tour du joueur $_currentPlayer de lancer les dés',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              // AnimatedDefaultTextStyle(
              //   duration: const Duration(milliseconds: 1000),
              //   style: TextStyle(
              //     color: _blinking ? Colors.white : Colors.transparent,
              //     fontSize: 22.0,
              //     fontWeight: FontWeight.bold,
              //   ),
              //   child:
              //       Text('Au tour du joueur $_currentPlayer de lancer les dés'),
              // ),
              // Affichage des dés
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'images/dice$_nber1.png',
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Image.asset(
                      'images/dice$_nber2.png',
                    ),
                  ),
                ],
              ),
              // Tableau de bord (visible ou caché)
              if (_showScoreboard)
                Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      // IconButton(
                      //   icon: Icon(_showScoreboard
                      //       ? Icons.visibility_off
                      //       : Icons.visibility),
                      //   onPressed: () {
                      //     setState(() {
                      //       _showScoreboard = !_showScoreboard;
                      //     });
                      //   },
                      // ),
                      // Scores des joueurs
                      Text('Nombre de parties: $_nbParties'),
                      Text('Joueur 1 : ${player1ScoreSum()}'),
                      Text('Joueur 2 : ${player2ScoreSum()}'),
                      const SizedBox(height: 20),
                      // Règles du jeu
                      const Text(
                        'Règles du jeu :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Lancez les dés. Pour chaque partie, celui qui a la plus grande somme, l\'emporte',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _randomlyGetTwoNumbers,
        tooltip: 'Lancer',
        child: const Icon(Icons.play_circle),
      ),
    );
  }
}
