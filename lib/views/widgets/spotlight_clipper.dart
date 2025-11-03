import 'package:flutter/material.dart';
import '../../services/onboarding_constants.dart';

// Custom clipper that cuts a hole (spotlight) in the overlay
class SpotlightClipper extends CustomClipper<Path> {
  final Rect? spotlightRect;
  final double padding;
  final double borderRadius;

  SpotlightClipper({
    this.spotlightRect,
    this.padding = OnboardingConstants.spotlightPadding,
    this.borderRadius = OnboardingConstants.spotlightBorderRadius,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    // Add the full screen as the outer path
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // If there's a spotlight area, cut it out
    if (spotlightRect != null) {
      // Expand the rect by padding
      final expandedRect = Rect.fromLTRB(
        spotlightRect!.left - padding,
        spotlightRect!.top - padding,
        spotlightRect!.right + padding,
        spotlightRect!.bottom + padding,
      );

      // Create rounded rectangle for the cutout
      final cutout = RRect.fromRectAndRadius(
        expandedRect,
        Radius.circular(borderRadius),
      );

      // Subtract the cutout from the overlay
      path.addRRect(cutout);
      path.fillType = PathFillType.evenOdd;
    }

    return path;
  }

  @override
  bool shouldReclip(SpotlightClipper oldClipper) {
    return oldClipper.spotlightRect != spotlightRect ||
        oldClipper.padding != padding ||
        oldClipper.borderRadius != borderRadius;
  }
}

// Custom painter to draw a border around the spotlight area
class SpotlightBorderPainter extends CustomPainter {
  final Rect spotlightRect;
  final double padding;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  SpotlightBorderPainter({
    required this.spotlightRect,
    this.padding = OnboardingConstants.spotlightPadding,
    this.borderRadius = OnboardingConstants.spotlightBorderRadius,
    this.borderColor = OnboardingConstants.spotlightBorderColor,
    this.borderWidth = OnboardingConstants.spotlightBorderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Expand the rect by padding
    final expandedRect = Rect.fromLTRB(
      spotlightRect.left - padding,
      spotlightRect.top - padding,
      spotlightRect.right + padding,
      spotlightRect.bottom + padding,
    );

    // Create rounded rectangle for the border
    final rrect = RRect.fromRectAndRadius(
      expandedRect,
      Radius.circular(borderRadius),
    );

    // Draw the border
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(SpotlightBorderPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect ||
        oldDelegate.padding != padding ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
