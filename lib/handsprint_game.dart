import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart' as flame_comp;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:handsprint/game_componants/game_background.dart';
import 'package:handsprint/game_componants/game_lane.dart';
import 'package:handsprint/game_componants/high_obstacles.dart';
import 'package:handsprint/game_componants/low_obstacles.dart';
import 'package:handsprint/game_componants/player_component.dart';
import 'package:handsprint/game_componants/coins.dart';
import 'package:handsprint/game_componants/player_state.dart';
import 'package:handsprint/services/game_audio_service.dart';

class HandsprintGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late GameLane gameLane;
  late PlayerComponent player;
  late TextComponent scoreText;

  int score = 0;
  VoidCallback? onReset;

 

  late flame_comp.Timer spawnTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await GameAudioService.preload();



    gameLane = GameLane(size);

    await add(GameBackground());

    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(20, 40),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 28,
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    await add(scoreText);

    player = PlayerComponent(gameLane);
    await add(player);

    spawnTimer = flame_comp.Timer(
      1.5,
      repeat: true,
      onTick: _spawnRandomItem,
    );
  }

  void _spawnRandomItem() {
    final rand = Random().nextDouble();
    if (rand < 0.45) {
      add(Coins(gameLane));
    } else if (rand < 0.70) {
      add(LowObstacles(gameLane));
    } else if (rand < 0.95) {
      add(HighObstacles(gameLane));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

 

    if (overlays.isActive('GameOver')) return;

    spawnTimer.update(dt);

    scoreText.text = 'Score: $score';
  }

  void reset() {
    overlays.remove('GameOver');

    score = 0;
    scoreText.text = 'Score: $score';

    player.position = Vector2(
      gameLane.getXForLane(LanePosition.center),
      size.y * 0.7,
    );

    children.whereType<Coins>().forEach(
      (coin) => coin.removeFromParent(),
    );

    children.whereType<LowObstacles>().forEach(
      (obs) => obs.removeFromParent(),
    );

    children.whereType<HighObstacles>().forEach(
      (obs) => obs.removeFromParent(),
    );

    player.currentLane = LanePosition.center;
    player.current = PlayerState.running;

    spawnTimer.start();

    resumeEngine();
    onReset?.call();
  }

  void collectCoin() {
    score += 10;
    GameAudioService.playRandomCoinVoice();
  }

  void gameOver() {
    pauseEngine();
    overlays.add('GameOver');
  }

  void onHandSwipeLeft() {
    if (!overlays.isActive('GameOver')) {
      player.moveToLeft();
    }
  }

  void onHandSwipeRight() {
    if (!overlays.isActive('GameOver')) {
      player.moveToRight();
    }
  }

  void onHandSwipeUp() {
    if (!overlays.isActive('GameOver')) {
      if (player.jump()) {
        GameAudioService.playJumpVoice();
      }
    }
  }

  void onHandSwipeDown() {
    if (!overlays.isActive('GameOver')) {
      player.slide();
    }
  }

 
}