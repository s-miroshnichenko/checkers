<h1 align="center">Flutter Checkers with AI</h1>

<p align="center">
  <em>A fully functional, cross-platform Checkers game built with Flutter.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Architecture-Clean-success?style=for-the-badge" alt="Clean Architecture" />
</p>

<p align="center">
	<strong><a href="README.md">Читать на русском 🇷🇺</a></strong>
</p>

> **Note:** This project was developed using an **AI-first approach** to test the limits of LLMs in building complex algorithmic games. The core architecture, Minimax AI, and game state were scaffolded via AI, and then meticulously refined, debugged, and integrated by me to ensure 100% bug-free operation. The primary focus is on clean architecture, state management, and AI orchestration rather than complex UI/UX design.

---

## 📸 Screenshots

<p align="center">
  <img src="screenshots/home_screen.png" alt="Checkers Game Image 1" width="45%" />
  &nbsp;&nbsp;
  <img src="screenshots/game_screen.png" alt="Checkers Game Image 2" width="45%" />
</p>

---

## ✨ Features

- 🎮 **Two Game Modes:** Play against another human locally or challenge the built-in AI.
- 🧠 **Custom AI Engine:** Features a custom-built AI opponent evaluating board states and utilizing recursive move generation using the Minimax algorithm.
- 📜 **Strict Rules Engine:** Implements official Russian Checkers rules, including:
  - Mandatory captures (multi-jumps).
  - "Flying Kings" (dames that can move across multiple empty squares).
- 🏗️ **Clean Architecture:** Strict separation between the Flutter UI (Presentation layer) and the core game logic (Domain layer). The AI and rules engine are written in pure Dart and have zero dependencies on the Flutter framework.
- 📱 **Responsive Board:** The game board automatically scales and constrains its size, making it fully playable on mobile, tablets, and web.

---

## 🏗️ Technical Highlights

This project highlights several key competencies for scalable Flutter development:

### 1. State Management (ViewModel Pattern)
The UI is decoupled from the game logic using a lightweight `GameController` that extends `ChangeNotifier`. The UI efficiently rebuilds only when necessary using `ListenableBuilder`, ensuring smooth performance without unnecessary widget tree rebuilds.

### 2. Pure Dart Domain Logic
The `BoardState`, `MoveGenerator`, and AI components are completely isolated from Flutter.
> **Why this matters:** This allows the AI to evaluate thousands of potential board states in milliseconds without any UI overhead. It also makes the core logic 100% unit-testable.

### 3. Complex Algorithmic Implementation (DFS & Backtracking)
The `MoveGenerator` handles complex scenarios like multi-jump capture sequences. It uses **Depth-First Search (DFS)** with **Backtracking** to simulate piece movement, check for promotions mid-jump, and revert the board state to evaluate alternative paths.

### 4. Memory Optimization
The AI evaluates future moves by creating deep copies (`clone()`) of the `BoardState`. This prevents state mutation issues during evaluation and ensures the visible UI does not "flicker" while the computer is "thinking".

---

## 🗂️ Project Structure

The codebase is organized for readability and maintainability:

```text
lib/
├── ai/
│   └── checkers_ai.dart        # AI logic and evaluation function
├── logic/
│   ├── game_controller.dart    # ViewModel managing UI state and interactions
│   └── move_generator.dart     # Pure Dart rules engine (valid moves, captures)
├── models/
│   ├── board_state.dart        # Data model representing the board at any given time
│   ├── game_mode.dart          # Enums for game modes
│   └── piece.dart              # Data model for individual checkers (men/kings)
├── screens/
│   └── home_screen.dart        # Game mode selection screen
├── widgets/
│   └── checker_board.dart      # The visual representation of the grid
└── main.dart                   # Application entry point
```

---

## 🚀 Getting Started

To run this project locally:

1. **Ensure you have Flutter installed.**
2. **Clone this repository:**
   ```bash
   git clone https://github.com/s-miroshnichenko/checkers
   ```
3. **Navigate to the project directory:**
   ```bash
   cd flutter-checkers
   ```
4. **Get dependencies:**
   ```bash
   flutter pub get
   ```
5. **Run the app:**
   ```bash
   flutter run
   ```

---

## 👨‍💻 About the Developer

I am a **Flutter Developer** specializing in building robust, architecturally sound applications. I focus on writing clean, maintainable code and solving complex logical problems.

If you are looking for a developer to build scalable mobile or web applications, feel free to contact me!