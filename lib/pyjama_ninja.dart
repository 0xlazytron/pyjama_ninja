import 'dart:io';
import 'dart:math';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PyjamaNinja extends FlameGame with PanDetector {
  late SpriteComponent fruit;
  int score = 0;
  int missed = 0;
  bool isPaused = false;
  Random random = Random();
  double speedY = 0; // Initial vertical speed (upward)
  double gravity = 9.8 * 100; // Gravitational acceleration
  bool isFalling = false; // Check if fruit is falling
  double maxPopHeight = 500; // Maximum pop height (adjustable)
  late double initialVelocity; // To be calculated

  late TextComponent scoreText;
  late TextComponent missText;

  @override
  Future<void> onLoad() async {
    // Load assets, including background
    await images.loadAll([
      'background.png',
      'fruite1.png',
      'fruite2.png',
      'fruite3.png',
      'fruite5.png',
      'fruite6.png',
      'fruite7.png',
      'pcoin.png'
    ]);
    FlameAudio.bgm.play('bgm.mp3');

    // Add background as the first component
    final background = SpriteComponent()
      ..sprite = Sprite(images.fromCache('background.png'))
      ..size = size; // Make sure background covers the screen
    add(background);

    // Initialize score and miss counters
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
    missText = TextComponent(
      text: 'Missed: $missed',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
    add(scoreText);
    add(missText);

    // Calculate initial velocity using v^2 = u^2 + 2as
    // For max height: u^2 = 2 * g * h
    initialVelocity = sqrt(2 * gravity * maxPopHeight);

    // Spawn the initial fruit
    spawnFruit();
  }

  void spawnFruit() {
    final fruitIndex = random.nextInt(3) + 1; // Randomly pick a fruit (1, 2, or 3)
    final fruitSprite = Sprite(images.fromCache('fruite$fruitIndex.png'));

    fruit = SpriteComponent()
      ..sprite = fruitSprite
      ..size = Vector2(100, 100)
      ..position = Vector2(random.nextDouble() * (size.x - 100), size.y); // Start at the bottom
    add(fruit);

    speedY = -initialVelocity; // Set the upward velocity
    isFalling = false;
  }

  // Handle the user touch to calculate the angle and split the fruit
  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!isPaused && fruit.parent != null) {
      if (fruit.toRect().contains(info.eventPosition.global.toOffset())) {
        // Calculate the angle of the slice based on the touch movement
        final touchPoint = info.eventPosition.global;
        final fruitCenter = fruit.position;
        final angle = atan2(touchPoint.y - fruitCenter.y, touchPoint.x - fruitCenter.x);

        // Split the fruit at this angle
        splitFruit(touchPoint, angle);
        FlameAudio.play('cut.wav');
        score++;
        scoreText.text = 'Score: $score';
        spawnFruit();
      }
    }
  }

  void splitFruit(Vector2 touchPoint, double angle) {
    // Split the fruit based on the calculated angle
    final leftHalf = SpriteComponent()
      ..sprite = fruit.sprite
      ..size = Vector2(50, 100) // Adjust size to represent half
      ..position = fruit.position - Vector2(25, 0); // Move left
    final rightHalf = SpriteComponent()
      ..sprite = fruit.sprite
      ..size = Vector2(50, 100) // Adjust size to represent half
      ..position = fruit.position + Vector2(25, 0); // Move right

    add(leftHalf);
    add(rightHalf);
    remove(fruit);

    // Apply movement and rotation to simulate the cut effect
    leftHalf.add(MoveByEffect(Vector2(-100 * cos(angle), -100 * sin(angle)), EffectController(duration: 2)));
    rightHalf.add(MoveByEffect(Vector2(100 * cos(angle), 100 * sin(angle)), EffectController(duration: 2)));

    leftHalf.add(RotateEffect.by(-0.5, EffectController(duration: 2)));
    rightHalf.add(RotateEffect.by(0.5, EffectController(duration: 2)));

    // Simulate gravity by moving both halves downward
    leftHalf.add(MoveByEffect(Vector2(0, 300), EffectController(duration: 2))); // Falling effect
    rightHalf.add(MoveByEffect(Vector2(0, 300), EffectController(duration: 2))); // Falling effect

    // Remove both halves after the effect completes
    leftHalf.add(RemoveEffect());
    rightHalf.add(RemoveEffect());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isPaused && fruit.parent != null) {
      // Apply the kinematic equation: v = u + at
      if (!isFalling) {
        fruit.position.y += speedY * dt; // Update position based on current velocity
        speedY += gravity * dt; // Update velocity with acceleration

        // Check if the fruit reached its peak
        if (speedY >= 0) {
          isFalling = true; // Start falling after reaching peak
        }
      } else {
        // Once falling, rotate the fruit and move it down
        fruit.angle += 2 * dt;
        fruit.position.y += 400 * dt; // Apply constant fall speed
        fruit.position.x += 100 * dt; // Move diagonally

        // Remove fruit when it moves outside of the screen
        if (fruit.position.y > size.y) {
          missed++;
          missText.text = 'Missed: $missed';
          remove(fruit);
          spawnFruit();
        }
      }
    }
  }

// Other methods like pauseGame, resumeGame, and exitGame remain unchanged...
}
