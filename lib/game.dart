import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_snake_game/direction_type.dart';
import 'package:just_audio/just_audio.dart';
import 'direction.dart';
import 'piece.dart';
import 'control_panel.dart';

class GamePage extends StatefulWidget {
  final String difficulty;  
  final int lowerBoundX, upperBoundX, lowerBoundY, upperBoundY;
  GamePage({
    required this.difficulty,
    required this.lowerBoundX,
    required this.upperBoundX,
    required this.lowerBoundY,
    required this.upperBoundY,
  });
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Offset> positions = [];
  int length = 5;
  int step = 20;
  final AudioPlayer _audioPlayerf = AudioPlayer();
  final AudioPlayer _audioPlayerg = AudioPlayer();
  Direction direction = Direction.right;
  // bool foodEaten = false;
  // bool gameOver = false;

  late Piece food;
  Offset? foodPosition;

  late double screenWidth;
  late double screenHeight;

  Timer? timer;
  double speed = 1;

  int score = 0;
  List<List<Offset>> obstacles = []; // Updated to handle 2x2 obstacles
  Timer? obstacleTimer;

  void draw(BuildContext context, Function restart) async {
    if (positions.isEmpty) {
      positions.add(getRandomPositionWithinRange());
    }
    while (length > positions.length) {
      positions.add(positions[positions.length - 1]);
    }
    for (var i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1];
    }

    positions[0] = await getNextPosition(positions[0]);

    if (detectSelfCollision() || detectObstacleCollision()) {
      if (timer != null && timer!.isActive) timer!.cancel();
      await Future.delayed(Duration(milliseconds: 500),
          () => showGameOverScreen(context, restart));
    }
  }

  bool detectSelfCollision() {
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] == positions[0]) {
        return true;
      }
    }
    return false;
  }

  bool detectObstacleCollision() {
    for (var obstacle in obstacles) {
      if (obstacle.contains(positions[0])) {
        return true;
      }
    }
    return false;
  }

  Offset getNextPosition(Offset position) {
    Offset? nextPosition;

    if (direction == Direction.right) {
      nextPosition = Offset(position.dx + step, position.dy);
    } else if (direction == Direction.left) {
      nextPosition = Offset(position.dx - step, position.dy);
    } else if (direction == Direction.up) {
      nextPosition = Offset(position.dx, position.dy - step);
    } else if (direction == Direction.down) {
      nextPosition = Offset(position.dx, position.dy + step);
    }

    if (nextPosition!.dx >= widget.upperBoundX) {
      nextPosition = Offset(widget.lowerBoundX.toDouble(), nextPosition.dy);
    } else if (nextPosition.dx < widget.lowerBoundX) {
      nextPosition = Offset(widget.upperBoundX.toDouble(), nextPosition.dy);
    }
    if (nextPosition.dy >= widget.upperBoundY) {
      nextPosition = Offset(nextPosition.dx, widget.lowerBoundY.toDouble());
    } else if (nextPosition.dy < widget.lowerBoundY) {
      nextPosition = Offset(nextPosition.dx, widget.upperBoundY.toDouble());
    }

    return nextPosition;
  }

  int roundToNearestTens(int num) {
    int divisor = step;
    int output = (num ~/ divisor) * divisor;
    if (output == 0) {
      output += step;
    }
    return output;
  }

  Offset getRandomPositionWithinRange() {
    int posX = Random().nextInt(widget.upperBoundX - widget.lowerBoundX) +
        widget.lowerBoundX;
    int posY = Random().nextInt(widget.upperBoundY - widget.lowerBoundY) +
        widget.lowerBoundY;
    return Offset(roundToNearestTens(posX).toDouble(),
        roundToNearestTens(posY).toDouble());
  }

  @override
  void dispose() {
    _audioPlayerf.dispose();
    _audioPlayerg.dispose();
    super.dispose();
  }

  void showGameOverScreen(BuildContext context, Function onRestart) {
    _audioPlayerg.seek(Duration.zero);
    _audioPlayerg.play();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 2),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            Center(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gradient text for "Game Over"
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 129, 5, 5),
                            Colors.red
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          'Game Over',
                          style: TextStyle(
                            fontSize: 50,
                            fontFamily: 'PixelFont',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            decoration:
                                TextDecoration.none, // Ensure no underline
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRestart();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          backgroundColor: Colors.green.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Restart',
                          style: TextStyle(
                            fontFamily: 'PixelFont',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        );
      },
    );
  }

  void drawFood() {
    if (foodPosition == null || detectFoodOnObstacle()) {
      foodPosition = getRandomPositionWithinRange();
    }

    if (foodPosition == positions[0]) {
      length++;
      speed += 0.25;
      score += 5;
      changeSpeed();
      _audioPlayerf.seek(Duration.zero);
      _audioPlayerf.play();
      foodPosition = getRandomPositionWithinRange();
    }

    food = Piece(
      posX: foodPosition!.dx.toInt(),
      posY: foodPosition!.dy.toInt(),
      size: step,
      color: const Color.fromARGB(255, 191, 32, 20),
      isAnimated: true,
    );
  }

  bool detectFoodOnObstacle() {
    for (var obstacle in obstacles) {
      if (obstacle.contains(foodPosition)) {
        return true;
      }
    }
    return false;
  }

  List<Piece> getPieces(BuildContext context, Function restart) {
    final pieces = <Piece>[];
    draw(context, restart);
    drawFood();

    for (var i = 0; i < length; i++) {
      if (i >= positions.length) {
        continue;
      }
      pieces.add(
        Piece(
          posX: positions[i].dx.toInt(),
          posY: positions[i].dy.toInt(),
          size: step,
          color: const Color.fromARGB(255, 31, 166, 4),
        ),
      );
    }

    return pieces;
  }

  List<Piece> getObstacles() {
    final obstaclePieces = <Piece>[];
    for (var obstacle in obstacles) {
      for (var offset in obstacle) {
        obstaclePieces.add(
          Piece(
            posX: offset.dx.toInt(),
            posY: offset.dy.toInt(),
            size: step,
            color: Colors.grey,
          ),
        );
      }
    }
    return obstaclePieces;
  }

  Widget getControls() {
    return ControlPanel(
      onTapped: (Direction newDirection) {
        direction = newDirection;
      },
    );
  }

  void changeSpeed() {
    if (timer != null && timer!.isActive) timer!.cancel();

    timer = Timer.periodic(Duration(milliseconds: 200 ~/ speed), (timer) {
      setState(() {});
    });
  }

  void changeObstaclePositions() {
    setState(() {
      obstacles = List.generate(5, (_) {
        final basePosition = getRandomPositionWithinRange();
        return [
          basePosition,
          basePosition.translate(step.toDouble(), 0),
          basePosition.translate(0, step.toDouble()),
          basePosition.translate(step.toDouble(), step.toDouble()),
        ];
      });
    });
  }

  void restart() {
    score = 0;
    length = 5;
    positions = [];
    direction = getRandomDirection();
    speed = 1;

    if (widget.difficulty == 'medium' || widget.difficulty == 'hard') {
      changeObstaclePositions();
    }
    if (widget.difficulty == 'hard') {
      obstacleTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        changeObstaclePositions();
      });
    }

    changeSpeed();
  }

  @override
  void initState() {
    super.initState();
    loadAudio();
    restart();
  }

  Future<void> loadAudio() async {
    await _audioPlayerf.setAsset('assets/audio/food.mp3');
    await _audioPlayerg.setAsset('assets/audio/game_over.mp3');
  }

  // void playFoodMusic() {
  //   if (foodEaten) {
  //     _audioPlayerf.play();
  //   } else {
  //     _audioPlayerf.pause();
  //   }
  // }

  // void playGameOverMusic() {
  //   if (gameOver) {
  //     _audioPlayerg.play();
  //   } else {
  //     _audioPlayerg.pause();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: Stack(
          children: [
            Stack(
              children: getPieces(context, restart),
            ),
            if (widget.difficulty != 'easy')
              Stack(
                children: getObstacles(),
              ),
            getControls(),
            food,
            getScore(),
          ],
        ),
      ),
    );
  }

  Direction getRandomDirection([DirectionType? type]) {
    if (type == DirectionType.horizontal) {
      bool random = Random().nextBool();
      return random ? Direction.right : Direction.left;
    } else if (type == DirectionType.vertical) {
      bool random = Random().nextBool();
      return random ? Direction.up : Direction.down;
    } else {
      int random = Random().nextInt(4);
      return Direction.values[random];
    }
  }

  Widget getScore() {
    return Positioned(
      top: 50.0,
      left: 20.0,
      child: Text(
        "Score: " + score.toString(),
        style: const TextStyle(fontSize: 24.0, fontFamily: 'PixelFont', color: Colors.white),
      ),
    );
  }
}
