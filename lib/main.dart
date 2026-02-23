import 'package:flutter/material.dart';

import 'logic/game_controller.dart';
import 'widgets/checker_board.dart';
import 'screens/home_screen.dart';
import 'models/game_mode.dart';

void main() {
  runApp(const CheckersApp());
}

/// The root widget of the Checkers application.
class CheckersApp extends StatelessWidget {
  const CheckersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Checkers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// The main game screen that hosts the checkerboard and handles game initialization.
class CheckersHomePage extends StatefulWidget {
  final GameMode gameMode;

  const CheckersHomePage({super.key, required this.gameMode});

  @override
  State<CheckersHomePage> createState() => _CheckersHomePageState();
}

class _CheckersHomePageState extends State<CheckersHomePage> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(gameMode: widget.gameMode);
  }

  @override
  void dispose() {
    // Best practice: dispose the controller when the widget is removed from the tree
    // to prevent memory leaks, since it acts as a ChangeNotifier.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gameMode == GameMode.humanVsHuman
              ? 'Checkers - Vs Human'
              : 'Checkers - Vs Computer',
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reset();
            },
            tooltip: 'New Game',
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            // Constrain the board's maximum width for tablets and web 
            // to maintain a playable aspect ratio.
            constraints: const BoxConstraints(maxWidth: 600),
            child: CheckerBoard(controller: _controller),
          ),
        ),
      ),
    );
  }
}
