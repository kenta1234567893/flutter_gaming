import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

import '../langaw-game.dart';
import '../view.dart';
import 'callout.dart';

class Fly {
  final LangawGame game;

  Rect flyRect;
  List<Sprite> flyingSprite;
  Sprite deadSprite;
  double flyingSpriteIndex = 0;

  bool isDead = false;
  bool isOffScreen = false;

  double get speed => game.tileSize * 3;
  Offset targetLocation;

  Callout callout;

  Fly(this.game) {
    setTargetLocation();
    callout = Callout(this);
  }

  void setTargetLocation() {
    double x = game.rnd.nextDouble() *
        (game.screenSize.width - (game.tileSize * 2.025));
    double y = game.rnd.nextDouble() *
        (game.screenSize.height - (game.tileSize * 2.025));
    targetLocation = Offset(x, y);
  }

  void render(Canvas c) {
    if (isDead) {
      deadSprite.renderRect(c, flyRect.inflate(2));
    } else {
      flyingSprite[flyingSpriteIndex.toInt()].renderRect(c, flyRect.inflate(2));
      if (game.activeView == View.playing) {
        callout.render(c);
      }
    }
  }

  void update(double t) {
    double stepDistance = speed * t;
    Offset toTarget = targetLocation - Offset(flyRect.left, flyRect.top);
    if (stepDistance < toTarget.distance) {
      Offset stepToTarget =
          Offset.fromDirection(toTarget.direction, stepDistance);
      flyRect = flyRect.shift(stepToTarget);
    } else {
      flyRect = flyRect.shift(toTarget);
      setTargetLocation();
    }

    if (isDead) {
      flyRect = flyRect.translate(0, game.tileSize * 12 * t);
      if (flyRect.top > game.screenSize.height) {
        isOffScreen = true;
      }
    } else {
      flyingSpriteIndex += 30 * t;
      if (flyingSpriteIndex >= 2) {
        flyingSpriteIndex -= 2;
      }
      callout.update(t);
    }
  }

  void onTapDown() {
    if (!isDead) {
      Flame.audio
          .play('sfx/ouch' + (game.rnd.nextInt(11) + 1).toString() + '.ogg');
      isDead = true;

      if (game.activeView == View.playing) {
        game.score += 1;
        if (game.score > (game.storage.getInt('highscore') ?? 0)) {
          game.storage.setInt('highscore', game.score);
          game.highscoreDisplay.updateHighscore();
        }
      }
    }
    if (game.soundButton.isEnabled) {
      Flame.audio
          .play('sfx/ouch' + (game.rnd.nextInt(11) + 1).toString() + '.ogg');
    }
  }
}
