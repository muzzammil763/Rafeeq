import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  /// Get MediaQueryData from BuildContext
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size from BuildContext
  Size get screenSize => mediaQuery.size;

  /// Get screen width from BuildContext
  double get screenWidth => screenSize.width;

  /// Get screen height from BuildContext
  double get screenHeight => screenSize.height;

  /// Get screen orientation from BuildContext
  Orientation get orientation => mediaQuery.orientation;

  /// Check if device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;

  /// Get device pixel ratio from BuildContext
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Get screen padding from BuildContext
  EdgeInsets get padding => mediaQuery.padding;

  /// Get screen viewInsets from BuildContext
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Get screen viewPadding from BuildContext
  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  /// Get top padding (status bar height) from BuildContext
  double get statusBarHeight => padding.top;

  /// Get bottom padding (bottom safe area) from BuildContext
  double get bottomPadding => padding.bottom;

  /// Get keyboard height from BuildContext
  double get keyboardHeight => viewInsets.bottom;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => keyboardHeight > 0;

  /// Get screen width percentage
  double widthPercent(double percent) => screenWidth * percent / 100;

  /// Get screen height percentage
  double heightPercent(double percent) => screenHeight * percent / 100;

  /// Check if screen width is less than [width]
  bool widthLessThan(double width) => screenWidth < width;

  /// Check if screen height is less than [height]
  bool heightLessThan(double height) => screenHeight < height;

  /// Check if screen width is greater than [width]
  bool widthGreaterThan(double width) => screenWidth > width;

  /// Check if screen height is greater than [height]
  bool heightGreaterThan(double height) => screenHeight > height;

  /// Check if device is mobile (width < 600)
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet (width >= 600 && width < 900)
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Check if device is desktop (width >= 900)
  bool get isDesktop => screenWidth >= 900;

  /// Get text scale factor from BuildContext
  double get textScaleFactor => mediaQuery.textScaler.scale(1.0);

  /// Check if dark mode is enabled
  bool get isDarkMode =>
      MediaQuery.platformBrightnessOf(this) == Brightness.dark;
}
