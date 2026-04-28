import 'package:flutter/material.dart';

class ResponsiveUtils {
  static Size getScreenSize(BuildContext context) =>
      MediaQuery.of(context).size;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isSmallScreen(BuildContext context) =>
      getScreenWidth(context) < 360;

  static bool isRegularScreen(BuildContext context) =>
      getScreenWidth(context) >= 360 && getScreenWidth(context) < 600;

  static bool isLargeScreen(BuildContext context) =>
      getScreenWidth(context) >= 600;

  static double getResponsivePadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 360) return 12;
    if (width < 600) return 16;
    return 24;
  }

  static double getResponsiveHorizontalPadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 360) return 12;
    if (width < 600) return 16;
    if (width < 900) return 20;
    return 32;
  }

  static double getResponsiveFontSize(BuildContext context,
      {required double baseSize}) {
    final width = getScreenWidth(context);
    final textScale = MediaQuery.of(context).textScaleFactor;

    if (width < 360) {
      return baseSize * 0.9 * textScale;
    } else if (width < 600) {
      return baseSize * textScale;
    } else {
      return baseSize * 1.1 * textScale;
    }
  }

  static double getResponsiveCardHeight(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 360) return 100;
    if (width < 600) return 120;
    return 140;
  }

  static double getResponsiveCardWidth(BuildContext context) {
    final width = getScreenWidth(context);
    final padding = getResponsiveHorizontalPadding(context);
    if (width < 600) {
      return width - (padding * 2);
    }
    // For larger screens, use max 60% width
    return (width * 0.6).clamp(250, double.infinity);
  }

  static double getResponsiveSpacing(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 360) return 8;
    if (width < 600) return 12;
    return 16;
  }
}
