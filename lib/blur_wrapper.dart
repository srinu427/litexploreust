import 'dart:ui';

import 'package:flutter/material.dart';

class BlurWrapper extends StatelessWidget{
  final BorderRadiusGeometry clipBorderRadius;
  final CustomClipper<RRect>? clipper;
  final Clip clipBehavior;
  final double sigma;
  final TileMode tileMode;
  final Widget child;

  const BlurWrapper(
    {
      this.clipBorderRadius = BorderRadius.zero,
      this.clipper,
      this.clipBehavior = Clip.antiAlias,
      required this.sigma,
      this.tileMode = TileMode.mirror,
      required this.child,
      super.key
    }
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: clipBorderRadius,
      clipper: clipper,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: tileMode
        ),
        child: child,
      ),
    );
  }
}