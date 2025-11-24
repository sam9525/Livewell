import 'package:flutter/material.dart';

/// Configuration constants for the onboarding system
class OnboardingConstants {
  // Private constructor to prevent instantiation
  OnboardingConstants._();

  // Animation durations
  static const Duration scrollDuration = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 400);
  static const Duration scrollSettleDelay = Duration(milliseconds: 100);

  // Animation curves
  static const Curve scrollCurve = Curves.easeInOut;
  static const Curve animationCurve = Curves.easeInOutCubic;

  // Spotlight configuration
  static const double spotlightPadding = 8.0;
  static const double spotlightBorderRadius = 12.0;
  static const double spotlightBorderWidth = 3.0;
  static const Color spotlightBorderColor = Color(0xFFFF6B35); // Orange
  static const double spotlightOverlayAlpha = 0.75;
  static const double spotlightScrollAlignment = 0.5; // Center in viewport

  // Tooltip configuration
  static const double tooltipSpacing = 20.0;
  static const double tooltipHorizontalPadding = 20.0;
  static const double tooltipDefaultBottomOffset = 100.0;
  static const double tooltipInternalPadding = 20.0;
  static const double tooltipBorderRadius = 20.0;
  static const double tooltipShadowBlur = 20.0;
  static const double tooltipShadowAlpha = 0.3;
  static const Offset tooltipShadowOffset = Offset(0, 10);

  // Progress indicator configuration
  static const double progressDotSize = 8.0;
  static const double progressDotSpacing = 3.0;
  static const double progressDotAlpha = 0.3;

  // Button configuration
  static const double buttonHorizontalPadding = 24.0;
  static const double buttonVerticalPadding = 12.0;
  static const double buttonBorderRadius = 20.0;
  static const double backButtonWidth = 60.0;

  // Typography
  static const double titleFontSize = 26.0;
  static const FontWeight titleFontWeight = FontWeight.bold;
  static const double descriptionFontSize = 18.0;
  static const FontWeight descriptionFontWeight = FontWeight.w400;
  static const double buttonFontSize = 18.0;
  static const FontWeight buttonFontWeight = FontWeight.bold;
  static const double skipButtonFontSize = 16.0;
  static const FontWeight skipButtonFontWeight = FontWeight.w400;
  static const double backButtonFontSize = 18.0;
  static const FontWeight backButtonFontWeight = FontWeight.w500;

  // Spacing
  static const double smallSpacing = 12.0;
  static const double mediumSpacing = 20.0;

  // Time-based onboarding configuration
  static const Duration onboardingTimeThreshold = Duration(minutes: 5);
}
