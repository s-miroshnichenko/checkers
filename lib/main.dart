import 'package:flutter/material.dart';
import 'logic/game_controller.dart';
import 'widgets/checker_board.dart';
import 'screens/home_screen.dart';
import 'models/game_mode.dart';

void main() {
  runApp(const CheckersApp());
}

/// Конфигурация приложения
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

/// Экран игры
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gameMode == GameMode.humanVsHuman
              ? 'Шашки — против человека'
              : 'Шашки — против компьютера',
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          // Кнопка перезапуска игры
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reset();
            },
            tooltip: 'Новая игра',
          ),
        ],
      ),
      backgroundColor: Colors.grey[300], // Серый фон вокруг доски
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Отступ от краев экрана
          child: ConstrainedBox(
            // Ограничиваем максимальную ширину для планшетов/веб-версии,
            // чтобы доска не была гигантской.
            constraints: const BoxConstraints(maxWidth: 600),
            child: CheckerBoard(controller: _controller),
          ),
        ),
      ),
    );
  }
}
