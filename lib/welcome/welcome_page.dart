import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_snake_game/game.dart';
import 'package:just_audio/just_audio.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? timer;
  List<Offset> snakePositions = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final int snakeLength = 10;
  final double stepSize = 20.0;
  final int step = 20;
  bool _playMusic = true; 
  late double screenWidth, screenHeight;
  int? lowerBoundX, upperBoundX, lowerBoundY, upperBoundY;

  @override
  void initState() {
    super.initState();
    _loadAudio();
    playMusic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 50), () {
        initSnake();
      });
    });
  }

  Future<void> _loadAudio() async {
    await _audioPlayer.setAsset('assets/audio/snake_game_bg.mp3');
    _audioPlayer.setLoopMode(LoopMode.one);
  }

  void playMusic() {
    if (_playMusic) {
      _audioPlayer.play();
    } else {
      _audioPlayer.pause();
    }
  }

  void initSnake() {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    
    double startX = 0;
    double startY = screenHeight - stepSize * 2;

    snakePositions = List.generate(
      snakeLength,
      (i) => Offset(startX - (i * stepSize), startY),
    );

    timer = Timer.periodic(Duration(milliseconds: 150), (_) {
      setState(moveSnake);
    });
  }

  void moveSnake() {
    for (int i = snakePositions.length - 1; i > 0; i--) {
      snakePositions[i] = snakePositions[i - 1];
    }

    snakePositions[0] = Offset(
      (snakePositions[0].dx + stepSize) % screenWidth,
      snakePositions[0].dy,
    );
  }

  int roundToNearestTens(int num) {
    return ((num + step - 1) ~/ step) * step;
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lowerBoundX = step;
    lowerBoundY = step;
    upperBoundX = roundToNearestTens(MediaQuery.of(context).size.width.toInt() - step);
    upperBoundY = roundToNearestTens(MediaQuery.of(context).size.height.toInt() - step);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SnakePainter(snakePositions, stepSize),
            ),
          ),
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
                  ...['easy', 'medium', 'hard'].map((difficulty) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        backgroundColor: _getButtonColor(difficulty).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _playMusic = !_playMusic;
                          playMusic();
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePage(
                              difficulty: difficulty,
                              lowerBoundX: lowerBoundX!,
                              lowerBoundY: lowerBoundY!,
                              upperBoundX: upperBoundX!,
                              upperBoundY: upperBoundY!,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        difficulty.capitalize(),
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          color: _getButtonColor(difficulty),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

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

extension StringCapitalizeExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
