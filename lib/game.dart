import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_snake_game/direction_type.dart';
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
  Direction direction = Direction.right;

  late Piece food;
  Offset? foodPosition;

  late double screenWidth;
  late double screenHeight;

  Timer? timer;
  double speed = 1;

  int score = 0;
  List<Offset> obstacles = [];
  Timer? obstacleTimer;

  void draw() async {
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
      await Future.delayed(
          Duration(milliseconds: 500), () => showGameOverDialog());
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
      if (obstacle == positions[0]) {
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

    if (nextPosition!.dx >= widget.upperBoundX!) {
      nextPosition = Offset(widget.lowerBoundX!.toDouble(), nextPosition.dy);
    } else if (nextPosition.dx < widget.lowerBoundX!) {
      nextPosition = Offset(widget.upperBoundX!.toDouble(), nextPosition.dy);
    }
    if (nextPosition.dy >= widget.upperBoundY!) {
      nextPosition = Offset(nextPosition.dx, widget.lowerBoundY!.toDouble());
    } else if (nextPosition.dy < widget.lowerBoundY!) {
      nextPosition = Offset(nextPosition.dx, widget.upperBoundY!.toDouble());
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
    int posX = Random().nextInt(widget.upperBoundX! - widget.lowerBoundX!) + widget.lowerBoundX!;
    int posY = Random().nextInt(widget.upperBoundY! - widget.lowerBoundY!) + widget.lowerBoundY!;
    return Offset(roundToNearestTens(posX).toDouble(),
        roundToNearestTens(posY).toDouble());
  }

  void showGameOverDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black,
              width: 3.0,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          title: Text(
            "Game Over",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Your game is over but you played well. Your score is $score.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                restart();
              },
              child: Text(
                "Restart",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void drawFood() {
    if (foodPosition == null) {
      foodPosition = getRandomPositionWithinRange();
    }

    if (foodPosition == positions[0]) {
      length++;
      speed += 0.25;
      score += 5;
      changeSpeed();

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

  List<Piece> getPieces() {
    final pieces = <Piece>[];
    draw();
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
      obstaclePieces.add(
        Piece(
          posX: obstacle.dx.toInt(),
          posY: obstacle.dy.toInt(),
          size: step,
          color: Colors.grey,
        ),
      );
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
      obstacles = List.generate(5, (_) => getRandomPositionWithinRange());
    });
  }

  void restart() {
    score = 0;
    length = 5;
    positions = [];
    direction = getRandomDirection();
    speed = 1;

    if (widget.difficulty == 'medium' || widget.difficulty == 'hard') {
      obstacles = List.generate(5, (_) => getRandomPositionWithinRange());
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
    restart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: Stack(
          children: [
            getPlayAreaBorder(),
            Stack(
              children: getPieces(),
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
      right: 40.0,
      child: Text(
        "Score: " + score.toString(),
        style: const TextStyle(fontSize: 24.0, color: Colors.white),
      ),
    );
  }

  Widget getPlayAreaBorder() {
    return Positioned(
      top: widget.lowerBoundY!.toDouble(),
      left: widget.lowerBoundX!.toDouble(),
      child: Container(
        width: (widget.upperBoundX! - widget.lowerBoundX! + step).toDouble(),
        height: (widget.upperBoundY! - widget.lowerBoundY! + step).toDouble(),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
