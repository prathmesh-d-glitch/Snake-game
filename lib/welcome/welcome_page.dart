import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_snake_game/game.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? timer;
  List<Offset> snakePositions = [];
  final int snakeLength = 10;
  final double stepSize = 20.0;
  late double screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSnake();
    });
  }

  void initSnake() {
    // Initialize the snake positions to move at the bottom
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    double startX = 0;
    double startY =
        screenHeight - stepSize * 2; // Near the bottom of the screen

    for (int i = 0; i < snakeLength; i++) {
      snakePositions.add(Offset(startX - (i * stepSize), startY));
    }

    // Timer to animate the snake
    timer = Timer.periodic(Duration(milliseconds: 150), (Timer timer) {
      setState(() {
        moveSnake();
      });
    });
  }

  void moveSnake() {
    for (int i = snakePositions.length - 1; i > 0; i--) {
      snakePositions[i] = snakePositions[i - 1];
    }

    // Move the head to the right and wrap around the screen
    snakePositions[0] =
        Offset(snakePositions[0].dx + stepSize, snakePositions[0].dy);

    // If the head moves out of the screen from the right side, bring it back to the left
    if (snakePositions[0].dx > screenWidth) {
      snakePositions[0] = Offset(0, snakePositions[0].dy);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Snake Animation at the bottom
          Positioned.fill(
            child: CustomPaint(
              painter: SnakePainter(snakePositions, stepSize),
            ),
          ),

          // Frosted Glass Effect with title and button
          Center(
            child: FrostedGlassEffect(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Snake Game",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 48,
                      fontFamily: 'PixelFont',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          backgroundColor: const Color.fromARGB(67, 244, 67, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GamePage()),
                      );
                    },
                    child: Text(
                      "Start Game",
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw the snake on the bottom of the screen
class SnakePainter extends CustomPainter {
  final List<Offset> snakePositions;
  final double size;

  SnakePainter(this.snakePositions, this.size);

  @override
  void paint(Canvas canvas, Size size) {
    Paint snakePaint = Paint()..color = Colors.red;

    for (var position in snakePositions) {
      canvas.drawCircle(position, this.size / 2, snakePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Widget for the Frosted Glass Effect
class FrostedGlassEffect extends StatelessWidget {
  final Widget child;

  FrostedGlassEffect({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.white.withOpacity(0.1),
          padding: EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
