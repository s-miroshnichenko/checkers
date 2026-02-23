import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../main.dart';

/// The initial screen of the app where the user selects the game mode.
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
            const Text(
              'CHECKERS',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select Game Mode',
              style: TextStyle(
                fontSize: 18,
                color: Colors.brown[200],
              ),
            ),
            const SizedBox(height: 60),
            _buildModeButton(
              context,
              icon: Icons.people,
              label: 'Vs Human',
              gameMode: GameMode.humanVsHuman,
            ),
            const SizedBox(height: 20),
            _buildModeButton(
              context,
              icon: Icons.computer,
              label: 'Vs Computer',
              gameMode: GameMode.humanVsComputer,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build consistent game mode selection buttons.
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
