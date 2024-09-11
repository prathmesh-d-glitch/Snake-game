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
  int step = 20;
  late double screenWidth, screenHeight;
  int? lowerBoundX, upperBoundX, lowerBoundY, upperBoundY;

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(Duration(milliseconds: 50), () {
      initSnake();
    });
  });
}


  void initSnake() {
  // Ensure correct screen dimensions
  screenWidth = MediaQuery.of(context).size.width;
  screenHeight = MediaQuery.of(context).size.height;
  
  print("Screen width: $screenWidth, height: $screenHeight");

  double startX = 0;
  double startY = screenHeight - stepSize * 2; // Near the bottom of the screen

  for (int i = 0; i < snakeLength; i++) {
    snakePositions.add(Offset(startX - (i * stepSize), startY));
  }

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

  int roundToNearestTens(int num) {
    int divisor = step;
    int output = (num ~/ divisor) * divisor;
    if (output == 0) {
      output += step;
    }
    return output;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lowerBoundX = step;
    lowerBoundY = step;
    upperBoundX =
        roundToNearestTens(MediaQuery.of(context).size.width.toInt() - step);
    upperBoundY =
        roundToNearestTens(MediaQuery.of(context).size.height.toInt() - step);
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

          // Frosted Glass Effect with title and buttons
          Center(
            child: FrostedGlassEffect(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Snake Game",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 50,
                      fontFamily: 'PixelFont',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Easy Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.green.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {
                      // Pass the difficulty level "easy"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePage(
                            difficulty: 'easy',
                            lowerBoundX: lowerBoundX!,
                            lowerBoundY: lowerBoundY!,
                            upperBoundX: upperBoundX!,
                            upperBoundY: upperBoundY!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Easy",
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        color: Colors.green,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Medium Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.orange.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {
                      // Pass the difficulty level "medium"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePage(
                            difficulty: 'medium',
                            lowerBoundX: lowerBoundX!,
                            lowerBoundY: lowerBoundY!,
                            upperBoundX: upperBoundX!,
                            upperBoundY: upperBoundY!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Medium",
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        color: Colors.orange,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Hard Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.red.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () {
                      // Pass the difficulty level "hard"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePage(
                            difficulty: 'hard',
                            lowerBoundX: lowerBoundX!,
                            lowerBoundY: lowerBoundY!,
                            upperBoundX: upperBoundX!,
                            upperBoundY: upperBoundY!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Hard",
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        color: Colors.red,
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
