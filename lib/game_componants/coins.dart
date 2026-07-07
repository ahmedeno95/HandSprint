import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:handsprint/const/game_images/game_images.dart';
import 'package:handsprint/game_componants/game_lane.dart';
import 'package:handsprint/game_componants/player_component.dart';
import 'package:handsprint/game_componants/player_state.dart';
import 'package:handsprint/handsprint_game.dart';

class Coins extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef<HandsprintGame> ,CollisionCallbacks {
  late LanePosition currentLane;
  final GameLane gameLane;
  

  final double scrollSpeed = 140.0; 
  late double targetX;
  
  // 2S EL SHEET
  final Vector2 frameSize = Vector2(160, 100);

  // SCROLLING EFFECT: start small and grow as it approaches the player
  double currentScale = 0.15; 

//initial size for cions
  Coins(this.gameLane) : super(size: Vector2(45,45));

  @override
  Future<void> onLoad() async {
    super.onLoad();
add(CircleHitbox()..collisionType = CollisionType.passive);

    final lanes = [LanePosition.left, LanePosition.center, LanePosition.right];
    currentLane = lanes[Random().nextInt(lanes.length)];

    final spriteSheet = await gameRef.images.load(GameImages.coins);
    
    // reading the first row of the sheet for the coin animation
    final coinsAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.14, 
        textureSize: frameSize,
        texturePosition: Vector2(0, 0),
      ),
    );
    
    animations = {
      PlayerState.running: coinsAnimation, 
    };
    current = PlayerState.running;

    anchor = Anchor.center;
    

    targetX = gameLane.getXForLane(currentLane);
    

    position = Vector2(targetX, gameRef.size.y * 0.35);
    scale = Vector2.all(currentScale);
  }

  @override
  void update(double dt) {
    super.update(dt);

//  move the coin down the screen
    position.y += scrollSpeed * dt;

    // perspective effect: gradually increase the scale as it gets closer to the player
    if (currentScale < 1.0) {
      currentScale += 0.7 * dt; 
      scale = Vector2.all(currentScale);
    }

    // remove the coin once it goes past the player and off the screen
    if (position.y > gameRef.size.y + 50) {
      removeFromParent();
    }
  }
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      gameRef.collectCoin(); 
      removeFromParent(); 
    }
  }

}