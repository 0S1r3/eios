import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(home: GameScreen()));
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool hasShownIntro = false;
  bool gameStarted = false;

  double cubeY = 0;
  double jumpVelocity = 0;
  int jumpCount = 0;
  bool gameOver = false;
  double distance = 0;
  double record = 0;

  final double gravity = 1500;
  final double jumpInitialVelocity = 600;

  List<Obstacle> obstacles = [];
  final double obstacleSpeed = 300;
  double obstacleSpawnTimer = 0;
  final double obstacleSpawnInterval = 2.0;

  List<Cloud> clouds = [];
  double cloudSpawnTimer = 0;
  final double cloudSpawnInterval = 3.0;

  late DateTime _lastUpdate;

  @override
  void initState() {
    super.initState();
    _lastUpdate = DateTime.now();
    _controller = AnimationController(vsync: this, duration: const Duration(hours: 1))
      ..addListener(_updateGame);
    _showIntroMessage();
  }

  Future<void> _playMusic() async {
    final state = _audioPlayer.state;
    if (state != PlayerState.playing) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('game_music.mp3'));
    }
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      _lastUpdate = DateTime.now();
      _controller.forward();
      _playMusic();
    });
  }

  void _updateGame() {
    if (!gameStarted || gameOver) return;

    final now = DateTime.now();
    final dt = now.difference(_lastUpdate).inMilliseconds / 1000.0;
    _lastUpdate = now;

    if (jumpCount > 0) {
      jumpVelocity -= gravity * dt;
      cubeY += jumpVelocity * dt;
      if (cubeY < 0) {
        cubeY = 0;
        jumpCount = 0;
        jumpVelocity = 0;
      }
    }

    for (var obs in obstacles) {
      obs.x -= obstacleSpeed * dt;
    }
    obstacles.removeWhere((obs) => obs.x + obs.width < 0);

    for (var cloud in clouds) {
      cloud.x -= cloud.speed * dt;
    }
    clouds.removeWhere((cloud) => cloud.x + cloud.width < 0);

    distance += obstacleSpeed * dt;

    final screenWidth = MediaQuery.of(context).size.width;

    obstacleSpawnTimer += dt;
    if (obstacleSpawnTimer >= obstacleSpawnInterval) {
      obstacleSpawnTimer = 0;
      double obsWidth = 20 + Random().nextInt(30).toDouble();
      double obsHeight = 30 + Random().nextInt(40).toDouble();
      obstacles.add(Obstacle(x: screenWidth, width: obsWidth, height: obsHeight));
    }

    cloudSpawnTimer += dt;
    if (cloudSpawnTimer >= cloudSpawnInterval) {
      cloudSpawnTimer = 0;
      final screenHeight = MediaQuery.of(context).size.height;
      double cloudY = Random().nextDouble() * (screenHeight / 2);
      double cloudWidth = 50 + Random().nextInt(80).toDouble();
      clouds.add(Cloud(
        x: screenWidth,
        y: cloudY,
        width: cloudWidth,
        height: cloudWidth * 0.6,
        speed: 20 + Random().nextInt(30).toDouble(),
      ));
    }

    if (_checkCollision()) {
      _onGameOver();
    }

    setState(() {});
  }

  bool _checkCollision() {
    const cubeX = 100.0;
    const cubeSize = 50.0;
    final groundY = MediaQuery.of(context).size.height - 80;
    final cubeRect = Rect.fromLTWH(cubeX, groundY - cubeSize - cubeY, cubeSize, cubeSize);

    for (var obs in obstacles) {
      final obsRect = Rect.fromLTWH(obs.x, groundY - obs.height, obs.width, obs.height);
      if (cubeRect.overlaps(obsRect)) return true;
    }
    return false;
  }

  void _onTap() {
    if (!gameStarted || gameOver) return;
    if (jumpCount < 2) {
      jumpCount++;
      jumpVelocity = jumpInitialVelocity;
    }
  }

  void _onGameOver() {
    gameOver = true;
    _controller.stop();
    if (distance > record) {
      record = distance;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Игра окончена"),
        content: Text("Дистанция: ${distance.toInt()}\nРекорд: ${record.toInt()}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text("Начать заново"),
          )
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      cubeY = 0;
      jumpVelocity = 0;
      jumpCount = 0;
      distance = 0;
      obstacles.clear();
      clouds.clear();
      obstacleSpawnTimer = 0;
      cloudSpawnTimer = 0;
      gameOver = false;
      gameStarted = true;
      _lastUpdate = DateTime.now();
      _controller.reset();
      _controller.forward();
    });
  }

  Future<void> _showIntroMessage() async {
    if (!hasShownIntro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text("В память"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/pasha.jpeg'),
                const SizedBox(height: 10),
                const Text("Эта игра посвящается Паше Технику — человеку, который навсегда оставил след в наших сердцах. Покойся с миром, легенда. Мы помним."),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _startGame();
                },
                child: const Text("Начать играть"),
              )
            ],
          ),
        );
      });
      hasShownIntro = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game")),
      body: GestureDetector(
        onTap: _onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return Stack(
              children: [
                CustomPaint(
                  size: size,
                  painter: GamePainter(
                    cubeY: cubeY,
                    obstacles: obstacles,
                    clouds: clouds,
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Рекорд: ${record.toInt()}",
                          style: const TextStyle(fontSize: 18, color: Colors.black)),
                      Text("Дистанция: ${distance.toInt()}",
                          style: const TextStyle(fontSize: 18, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Obstacle {
  double x;
  final double width;
  final double height;
  Obstacle({required this.x, required this.width, required this.height});
}

class Cloud {
  double x;
  final double y;
  final double width;
  final double height;
  final double speed;

  Cloud({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
  });
}

class GamePainter extends CustomPainter {
  final double cubeY;
  final List<Obstacle> obstacles;
  final List<Cloud> clouds;

  GamePainter({
    required this.cubeY,
    required this.obstacles,
    required this.clouds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - 80;

    final skyPaint = Paint()..color = Colors.lightBlue.shade200;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, groundY), skyPaint);

    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.97)
      ..style = PaintingStyle.fill;

    for (var cloud in clouds) {
      final centerX = cloud.x + cloud.width / 2;
      final centerY = cloud.y + cloud.height / 2;
      final baseRadius = cloud.height * 0.4;

      // Центральный круг
      canvas.drawCircle(
        Offset(centerX, centerY),
        baseRadius * 1.3,
        cloudPaint,
      );

      // Левый круг
      canvas.drawCircle(
        Offset(centerX - baseRadius * 0.7, centerY),
        baseRadius * 0.9,
        cloudPaint,
      );

      // Правый круг
      canvas.drawCircle(
        Offset(centerX + baseRadius * 0.7, centerY),
        baseRadius * 0.9,
        cloudPaint,
      );

      // Верхний круг
      canvas.drawCircle(
        Offset(centerX, centerY - baseRadius * 0.5),
        baseRadius * 0.7,
        cloudPaint,
      );

      // Нижний круг
      canvas.drawCircle(
        Offset(centerX, centerY + baseRadius * 0.5),
        baseRadius * 0.6,
        cloudPaint,
      );
    }

    final groundPaint = Paint()..color = Colors.green;
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, 80), groundPaint);

    const cubeSize = 50.0;
    final cubePaint = Paint()..color = Colors.blue;
    const cubeX = 100.0;
    final cubeTop = groundY - cubeSize - cubeY;
    canvas.drawRect(Rect.fromLTWH(cubeX, cubeTop, cubeSize, cubeSize), cubePaint);

    final obstaclePaint = Paint()..color = Colors.red;
    for (var obs in obstacles) {
      final obsY = groundY - obs.height;
      canvas.drawRect(Rect.fromLTWH(obs.x, obsY, obs.width, obs.height), obstaclePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}