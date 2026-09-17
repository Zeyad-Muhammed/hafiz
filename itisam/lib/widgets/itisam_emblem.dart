import 'package:flutter/material.dart';

import '../theme.dart';
import 'rope_ring.dart';

class ItisamEmblem extends StatelessWidget {
  const ItisamEmblem({
    super.key,
    this.ropeProgress = 1,
    this.starProgress = 1,
    this.rotation = 0,
    this.size = 150,
    this.showRope = true,
    this.showStar = true,
  });

  final double ropeProgress;
  final double starProgress;
  final double rotation;
  final double size;
  final bool showRope;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RopeRingPainter(
          progress: showRope ? ropeProgress : 0,
          color: ItisamColors.gold,
          darkColor: ItisamColors.goldLight,
          rotation: rotation,
        ),
        child: Center(
          child: SizedBox(
            width: size * 0.52,
            height: size * 0.52,
            child: CustomPaint(
              painter: IslamicStarPainter(
                progress: showStar ? starProgress : 0,
                color: ItisamColors.goldLight,
                edgeColor: ItisamColors.gold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}