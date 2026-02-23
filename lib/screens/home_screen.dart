import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Заголовок
            const Text(
              'Шашки',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Выберите режим игры',
              style: TextStyle(
                fontSize: 18,
                color: Colors.brown[200],
              ),
            ),
            const SizedBox(height: 60),

            // Кнопка "Против человека"
            _buildModeButton(
              context,
              icon: Icons.people,
              label: 'Против человека',
              gameMode: GameMode.humanVsHuman,
            ),
            const SizedBox(height: 20),

            // Кнопка "Против компьютера"
            _buildModeButton(
              context,
              icon: Icons.computer,
              label: 'Против компьютера',
              gameMode: GameMode.humanVsComputer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required GameMode gameMode,
  }) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckersHomePage(gameMode: gameMode),
            ),
          );
        },
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
