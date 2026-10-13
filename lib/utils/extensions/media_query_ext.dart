import 'package:flutter/material.dart';

/// Extensions on [MediaQueryData] for easier access to common properties
/// and helper methods for responsive design
extension MediaQueryExt on MediaQueryData {
  /// Returns true if the device is in portrait orientation
  bool get isPortrait => orientation == Orientation.portrait;

  /// Returns true if the device is in landscape orientation
  bool get isLandscape => orientation == Orientation.landscape;

  /// Returns true if the width is less than 600dp, typically considered a phone
  bool get isPhone => size.width < 600;

  /// Returns true if the width is between 600dp and 840dp, typically considered a small tablet
  bool get isSmallTablet => size.width >= 600 && size.width < 840;

  /// Returns true if the width is between 840dp and 1200dp, typically considered a large tablet
  bool get isLargeTablet => size.width >= 840 && size.width < 1200;

  /// Returns true if the width is 1200dp or greater, typically considered a desktop
  bool get isDesktop => size.width >= 1200;

  /// Returns true if the current theme brightness is dark
  bool get isDarkMode => platformBrightness == Brightness.dark;

  /// Returns the safe horizontal padding
  EdgeInsets get safePaddingHorizontal =>
      EdgeInsets.symmetric(horizontal: padding.horizontal);

  /// Returns the safe vertical padding
  EdgeInsets get safePaddingVertical =>
      EdgeInsets.symmetric(vertical: padding.vertical);

  /// Calculate responsive width based on screen percentage
  double widthPercent(double percent) => size.width * percent / 100;

  /// Calculate responsive height based on screen percentage
  double heightPercent(double percent) => size.height * percent / 100;

  /// Returns a value based on the current screen size
  /// - phone: returns the first value
  /// - small tablet: returns the second value
  /// - large tablet: returns the third value
  /// - desktop: returns the fourth value
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? largeTablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? largeTablet ?? tablet ?? mobile;
    if (isLargeTablet) return largeTablet ?? tablet ?? mobile;
    if (isSmallTablet) return tablet ?? mobile;
    return mobile;
  }

  /// Returns a responsive font size based on the screen width
  /// The size will be scaled between the min and max values
  double responsiveFontSize({required double size, double? min, double? max}) {
    final double fontSize = size * textScaler.scale(1.0);
    if (min != null && fontSize < min) return min;
    if (max != null && fontSize > max) return max;
    return fontSize;
  }

  /// Returns a responsive width constraint
  double responsiveWidth({
    required double baseWidth,
    double? minWidth,
    double? maxWidth,
  }) {
    final width = baseWidth * (size.width / 375.0); // Using iPhone 8 as base
    if (minWidth != null && width < minWidth) return minWidth;
    if (maxWidth != null && width > maxWidth) return maxWidth;
    return width;
  }

  /// Returns a responsive height constraint
  double responsiveHeight({
    required double baseHeight,
    double? minHeight,
    double? maxHeight,
  }) {
    final height =
        baseHeight * (size.height / 812.0); // Using iPhone 12 as base
    if (minHeight != null && height < minHeight) return minHeight;
    if (maxHeight != null && height > maxHeight) return maxHeight;
    return height;
  }

  /// Returns a padding that adapts to the screen size
  EdgeInsets responsivePadding({
    required EdgeInsets small,
    EdgeInsets? medium,
    EdgeInsets? large,
  }) {
    if (isLargeTablet || isDesktop) return large ?? medium ?? small;
    if (isSmallTablet) return medium ?? small;
    return small;
  }
}
