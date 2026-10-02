import 'package:flutter/foundation.dart';

/// Shared between the play page and the catch animation: how far the Pokemon
/// has been pulled into (or released from) the ball. The page applies it to
/// the Pokemon's sprite; the animation drives it from its timeline.
class CatchStageController extends ChangeNotifier {
  /// 0 = Pokemon fully visible, 1 = fully inside the ball.
  double absorb = 0;

  /// Vertical anchor (-1 top .. 1 bottom of the sprite) the Pokemon shrinks
  /// toward — wherever the ball currently is.
  double anchorY = -0.6;

  void update({required double absorb, required double anchorY}) {
    if (this.absorb == absorb && this.anchorY == anchorY) return;
    this.absorb = absorb;
    this.anchorY = anchorY;
    notifyListeners();
  }
}
