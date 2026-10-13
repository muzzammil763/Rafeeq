import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const List<BoxShadow> kSubtleBoxShadow = [
  BoxShadow(
    color: Color(0x0D000000), // black with 5% alpha
    blurRadius: 4,
    offset: Offset(0, 2),
  ),
];

// 041C32
// 04293A
// 064663
// ECB365
const _brandBlueDark = Color(0xff041c32); // Background
const _brandBlueMedium = Color(0xff04293a); // Surface / Container
const _brandBlueLight = Color(0xff064663); // Primary
const _brandLime = Colors.limeAccent; // Accent / Text
const _brandWhite = Color(0xffffffff);

// Emerald Green
const _brandGreenDark = Color(0xff011c11);
const _brandGreenMedium = Color(0xff032d1d);
const _brandGreenLight = Color(0xff0d5236);
const _brandGreenAccent = Color(0xff00ff9d);

/*
// Royal Purple
const _brandPurpleDark = Color(0xff1a0b2e);
const _brandPurpleMedium = Color(0xff2d1b4e);
const _brandPurpleLight = Color(0xff4a148c);
const _brandPurpleAccent = Color(0xffe0b0ff);

// Sunset Orange
const _brandOrangeDark = Color(0xff2b0e00);
const _brandOrangeMedium = Color(0xff451e03);
const _brandOrangeLight = Color(0xffb34500);
const _brandOrangeAccent = Color(0xffff6d00);

// Sakura Pink
const _brandPinkDark = Color(0xff2a0a12);
const _brandPinkMedium = Color(0xff4a121f);
const _brandPinkLight = Color(0xff880e4f);
const _brandPinkAccent = Color(0xffff80ab);

// Midnight Indigo
const _brandIndigoDark = Color(0xff1a237e);
const _brandIndigoMedium = Color(0xff283593);
const _brandIndigoLight = Color(0xff0d47a1);
const _brandIndigoAccent = Color(0xff8c9eff);

// Electric Violet
const _brandVioletDark = Color(0xff12005e);
const _brandVioletMedium = Color(0xff311b92);
const _brandVioletLight = Color(0xff4527a0);
const _brandVioletAccent = Color(0xffb388ff);
*/

// Ocean Teal
const _brandTealDark = Color(0xff001e1d);
const _brandTealMedium = Color(0xff003330);
const _brandTealLight = Color(0xff006064);
const _brandTealAccent = Color(0xff00e5ff);

/*
// Golden Amber
const _brandAmberDark = Color(0xff1f1501);
const _brandAmberMedium = Color(0xff362502);
const _brandAmberLight = Color(0xff6f4c02);
const _brandAmberAccent = Color(0xffffc400);
*/

// Slate Grey
const _brandGreyDark = Color(0xff121212);
const _brandGreyMedium = Color(0xff252525);
const _brandGreyLight = Color(0xff455a64);
const _brandGreyAccent = Color(0xffcfd8dc);

class AppThemeOption {
  final String name;
  final Color seedColor;
  final Color? primaryOverride;
  final Color? onPrimaryOverride;
  final Color? secondaryOverride;
  final Color? surfaceOverride;
  final Color? onSurfaceOverride;
  final Color? primaryContainerOverride;

  const AppThemeOption({
    required this.name,
    required this.seedColor,
    this.primaryOverride,
    this.onPrimaryOverride,
    this.secondaryOverride,
    this.surfaceOverride,
    this.onSurfaceOverride,
    this.primaryContainerOverride,
  });
}

class AppTheme {
  const AppTheme._();

  static const brandLime = _brandLime;

  static const List<AppThemeOption> availableOptions = [
    AppThemeOption(
      name: 'Slate Grey',
      seedColor: Colors.blueGrey,
      primaryOverride: _brandGreyAccent,
      onPrimaryOverride: _brandGreyDark,
      secondaryOverride: _brandGreyLight,
      surfaceOverride: _brandGreyDark,
      onSurfaceOverride: _brandGreyAccent,
      primaryContainerOverride: _brandGreyMedium,
    ),
    AppThemeOption(
      name: 'Lime & Blue',
      seedColor: _brandBlueDark,
      primaryOverride: _brandLime,
      onPrimaryOverride: _brandBlueDark,
      secondaryOverride: _brandBlueLight,
      surfaceOverride: _brandBlueDark,
      onSurfaceOverride: _brandLime,
      primaryContainerOverride: _brandBlueMedium,
    ),
    AppThemeOption(
      name: 'Emerald Green',
      seedColor: Colors.green,
      primaryOverride: _brandGreenAccent,
      onPrimaryOverride: _brandGreenDark,
      secondaryOverride: _brandGreenLight,
      surfaceOverride: _brandGreenDark,
      onSurfaceOverride: _brandGreenAccent,
      primaryContainerOverride: _brandGreenMedium,
    ),
    /*
    AppThemeOption(
      name: 'Royal Purple',
      seedColor: Colors.deepPurple,
      primaryOverride: _brandPurpleAccent,
      onPrimaryOverride: _brandPurpleDark,
      secondaryOverride: _brandPurpleLight,
      surfaceOverride: _brandPurpleDark,
      onSurfaceOverride: _brandPurpleAccent,
      primaryContainerOverride: _brandPurpleMedium,
    ),
    AppThemeOption(
      name: 'Sunset Orange',
      seedColor: Colors.orange,
      primaryOverride: _brandOrangeAccent,
      onPrimaryOverride: _brandOrangeDark,
      secondaryOverride: _brandOrangeLight,
      surfaceOverride: _brandOrangeDark,
      onSurfaceOverride: _brandOrangeAccent,
      primaryContainerOverride: _brandOrangeMedium,
    ),
    AppThemeOption(
      name: 'Sakura Pink',
      seedColor: Colors.pink,
      primaryOverride: _brandPinkAccent,
      onPrimaryOverride: _brandPinkDark,
      secondaryOverride: _brandPinkLight,
      surfaceOverride: _brandPinkDark,
      onSurfaceOverride: _brandPinkAccent,
      primaryContainerOverride: _brandPinkMedium,
    ),
    AppThemeOption(
      name: 'Midnight Indigo',
      seedColor: Colors.indigo,
      primaryOverride: _brandIndigoAccent,
      onPrimaryOverride: _brandIndigoDark,
      secondaryOverride: _brandIndigoLight,
      surfaceOverride: _brandIndigoDark,
      onSurfaceOverride: _brandIndigoAccent,
      primaryContainerOverride: _brandIndigoMedium,
    ),
    AppThemeOption(
      name: 'Electric Violet',
      seedColor: Colors.deepPurpleAccent,
      primaryOverride: _brandVioletAccent,
      onPrimaryOverride: _brandVioletDark,
      secondaryOverride: _brandVioletLight,
      surfaceOverride: _brandVioletDark,
      onSurfaceOverride: _brandVioletAccent,
      primaryContainerOverride: _brandVioletMedium,
    ),
    */
    AppThemeOption(
      name: 'Ocean Teal',
      seedColor: Colors.teal,
      primaryOverride: _brandTealAccent,
      onPrimaryOverride: _brandTealDark,
      secondaryOverride: _brandTealLight,
      surfaceOverride: _brandTealDark,
      onSurfaceOverride: _brandTealAccent,
      primaryContainerOverride: _brandTealMedium,
    ),
    /*
    AppThemeOption(
      name: 'Golden Amber',
      seedColor: Colors.amber,
      primaryOverride: _brandAmberAccent,
      onPrimaryOverride: _brandAmberDark,
      secondaryOverride: _brandAmberLight,
      surfaceOverride: _brandAmberDark,
      onSurfaceOverride: _brandAmberAccent,
      primaryContainerOverride: _brandAmberMedium,
    ),
    */
  ];

  static ThemeData getTheme(
    int index, {
    String? languageCode,
    Brightness brightness = Brightness.dark,
  }) {
    final option =
        availableOptions.elementAtOrNull(index) ?? availableOptions[0];
    final isLight = brightness == Brightness.light;
    final colorScheme = isLight
        ? ColorScheme.fromSeed(
            seedColor: const Color(0xFF176765),
            brightness: Brightness.light,
          ).copyWith(
            primary: const Color(0xFF176765),
            onPrimary: Colors.white,
            secondary: const Color(0xFF287D79),
            onSecondary: const Color(0xFF202624),
            surface: const Color(0xFFFFFEFA),
            onSurface: const Color(0xFF202624),
            primaryContainer: const Color(0xFFFFF5E3),
            onPrimaryContainer: const Color(0xFF202624),
          )
        : ColorScheme.fromSeed(
            seedColor: option.seedColor,
            brightness: Brightness.dark,
            primary: option.primaryOverride,
            onPrimary: option.onPrimaryOverride,
            secondary: option.secondaryOverride,
            onSecondary: _brandWhite,
            surface: option.surfaceOverride,
            onSurface: option.onSurfaceOverride,
          );

    final effectiveTextColor = isLight
        ? colorScheme.onSurface
        : option.onSurfaceOverride ?? colorScheme.onSurface;
    final effectiveBackgroundColor = isLight
        ? colorScheme.surface
        : option.surfaceOverride ?? colorScheme.surface;
    final effectivePrimaryContainer = isLight
        ? colorScheme.primaryContainer
        : option.primaryContainerOverride ??
              (option.primaryOverride != null
                  ? option.primaryOverride!.withValues(alpha: 0.8)
                  : colorScheme.primaryContainer);

    // Create the RafeeqTheme extension
    final rafeeqTheme = RafeeqTheme(
      bgColor: effectiveBackgroundColor,
      primaryColor: effectivePrimaryContainer,
      secondaryColor: colorScheme.secondary,
      textColor: effectiveTextColor,
    );

    final themeData = ThemeData(
      useMaterial3: true,
      fontFamily: languageCode == 'ur'
          ? 'Jameel Noori Nastaleeq'
          : 'GoogleSans',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: effectiveBackgroundColor,
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: effectiveTextColor),
        backgroundColor: rafeeqTheme.primaryColor,
        foregroundColor: effectiveTextColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: (languageCode == 'ur')
            ? TextStyle(
                fontFamily: 'Jameel Noori Nastaleeq',
                color: effectiveTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              )
            : TextStyle(
                fontFamily: 'GoogleSans',
                color: effectiveTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: effectiveBackgroundColor,
          statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
          statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: effectiveBackgroundColor,
          systemNavigationBarIconBrightness: isLight
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: effectiveBackgroundColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.primary.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: effectivePrimaryContainer, // Using the "Container" color
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: effectiveBackgroundColor,
        indicatorColor: colorScheme.primary,
        labelTextStyle: WidgetStatePropertyAll(
          (languageCode == 'ur')
              ? TextStyle(
                  fontFamily: 'Jameel Noori Nastaleeq',
                  color: effectiveTextColor,
                  fontWeight: FontWeight.w500,
                )
              : TextStyle(
                  fontFamily: 'GoogleSans',
                  color: effectiveTextColor,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: (languageCode == 'ur')
            ? TextStyle(
                fontFamily: 'Jameel Noori Nastaleeq',
                color: effectiveTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              )
            : TextStyle(
                fontFamily: 'GoogleSans',
                color: effectiveTextColor,
                fontSize: 15,
              ),
        subtitleTextStyle: (languageCode == 'ur')
            ? TextStyle(
                fontFamily: 'Jameel Noori Nastaleeq',
                color: effectiveTextColor,
                fontSize: 14,
              )
            : TextStyle(
                fontFamily: 'GoogleSans',
                color: effectiveTextColor,
                fontSize: 12,
              ),
        iconColor: colorScheme.primary,
        textColor: effectiveTextColor,
        tileColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.primary.withValues(alpha: 0.5);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.primary.withValues(alpha: 0.5),
        indicatorColor: colorScheme.primary,
        dividerColor: Colors.transparent,
      ),
      extensions: [rafeeqTheme],
    );

    final baseTextTheme = (languageCode == 'ur')
        ? themeData.textTheme.apply(fontFamily: 'Jameel Noori Nastaleeq')
        : themeData.textTheme.apply(fontFamily: 'GoogleSans');

    return themeData.copyWith(
      textTheme: baseTextTheme.copyWith(
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: effectiveTextColor,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: colorScheme.primary, // Titles in Accent/Primary
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class RafeeqTheme extends ThemeExtension<RafeeqTheme> {
  final Color bgColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;

  const RafeeqTheme({
    required this.bgColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
  });

  @override
  ThemeExtension<RafeeqTheme> copyWith({
    Color? bgColor,
    Color? primaryColor,
    Color? secondaryColor,
    Color? textColor,
  }) {
    return RafeeqTheme(
      bgColor: bgColor ?? this.bgColor,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  ThemeExtension<RafeeqTheme> lerp(
    ThemeExtension<RafeeqTheme>? other,
    double t,
  ) {
    if (other is! RafeeqTheme) {
      return this;
    }
    return RafeeqTheme(
      bgColor: Color.lerp(bgColor, other.bgColor, t)!,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
    );
  }
}

extension RafeeqThemeX on BuildContext {
  RafeeqTheme get mainTheme => Theme.of(this).extension<RafeeqTheme>()!;
}
