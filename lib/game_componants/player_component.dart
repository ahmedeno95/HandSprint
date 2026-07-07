import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:handsprint/const/game_images/game_images.dart';
import 'package:handsprint/game_componants/game_lane.dart';
import 'package:handsprint/game_componants/player_state.dart';

class PlayerComponent extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef, CollisionCallbacks {
  LanePosition currentLane = LanePosition.center;
  final GameLane gameLane;
  
  final double moveSpeed = 15.0; 
  late double targetX;
  late double groundY;


  double yVelocity = 0;
  final double gravity = 1700.0; 
  final double jumpForce = -700.0; 
  double slideTimer = 0.0;
  final double slideDuration = 0.6; 


  final Vector2 frameSize = Vector2(125, 125);

  PlayerComponent(this.gameLane) : super(size: Vector2(110, 110)); 

  @override
  Future<void> onLoad() async {
    super.onLoad();
add(CircleHitbox(radius: size.x * 0.4, anchor: Anchor.center, position: size / 2));
    final spriteSheet = await gameRef.images.load(GameImages.player);
// run animation (first row of the sprite sheet)
    final runAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 4, 
        stepTime: 0.1,
        textureSize: frameSize,
        texturePosition: Vector2(0, 0),
      ),
    );
// jump animation (second row: we moved down by one frame which is 125 on the Y axis)
    final jumpAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: frameSize,
        texturePosition: Vector2(0, 125),
      ),
    );

// sliding animation (the third row: we moved down 2 frames which is 250 on the Y axis)
    final slideAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: frameSize,
        texturePosition: Vector2(0, 244),
      ),
    );

    // configure the animations map and set the initial state
    animations = {
      PlayerState.running: runAnimation,
      PlayerState.jumping: jumpAnimation,
      PlayerState.sliding: slideAnimation,
    };
    current = PlayerState.running;

    anchor = Anchor.center;
    targetX = gameLane.getXForLane(currentLane);
    

    groundY = gameRef.size.y * 0.78; 
    position = Vector2(targetX, groundY);
  }

  // movement functions for lane switching
  void moveToLeft() {
    if (currentLane == LanePosition.right) {
      currentLane = LanePosition.center;
    } else if (currentLane == LanePosition.center) {
      currentLane = LanePosition.left;
    }
  }

  void moveToRight() {
    if (currentLane == LanePosition.left) {
      currentLane = LanePosition.center;
    } else if (currentLane == LanePosition.center) {
      currentLane = LanePosition.right;
    }
  }


  bool jump() {
    if (current != PlayerState.running) {
      return false;
    }

    current = PlayerState.jumping;
    yVelocity = jumpForce;
    return true;
  }


  void slide() {
    if (current == PlayerState.running) {
      current = PlayerState.sliding;
      slideTimer = slideDuration;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    targetX = gameLane.getXForLane(currentLane);
    final double lerpFactor = (moveSpeed * dt).clamp(0.0, 1.0);
    position.x += (targetX - position.x) * lerpFactor;

    
    if (current == PlayerState.jumping) {
      yVelocity += gravity * dt;
      position.y += yVelocity * dt;

      if (position.y >= groundY) {
        position.y = groundY;
        yVelocity = 0;
        current = PlayerState.running; 
      }
    }

  
    if (current == PlayerState.sliding) {
      slideTimer -= dt;
      if (slideTimer <= 0) {
        current = PlayerState.running; 
      }
    }

 
    if (current != PlayerState.jumping) {
      position.y = groundY;
    }
  }
}