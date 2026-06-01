import 'package:flutter/material.dart';

enum ThemeType { blue, green, orange }

class AppTheme extends ChangeNotifier {
  static final AppTheme _instance = AppTheme._internal();
  static AppTheme get instance => _instance;

  AppTheme._internal() {
    // Initialize with default theme
    setTheme(ThemeType.blue);
  }

  Color _primaryColor = const Color(0xFF3374F6);
  Color _secondaryColor = const Color(0xFF4EAEF7);
  Color _tertiaryColor = const Color(0xFF76FBFD);
  Color _mutedColor = const Color(0xFF63A6D1);
  Color _backgroundColor = const Color(0xFFE3F2FD);
  Color _iconBgColor = const Color(0x334EAEF7);

  // Generic Getters
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get tertiaryColor => _tertiaryColor;
  Color get mutedColor => _mutedColor;
  Color get backgroundColor => _backgroundColor;
  Color get iconBgColor => _iconBgColor;

  // Legacy/Fallback Getters
  Color get primaryDeepBlue => _primaryColor;
  Color get secondaryLightBlue => _secondaryColor;
  Color get tertiaryCyan => _tertiaryColor;
  Color get mutedBlue => _mutedColor;
  Color get lightBlueBg => _backgroundColor;


  ThemeType _currentTheme = ThemeType.blue;
  ThemeType get currentTheme => _currentTheme;

  void setTheme(ThemeType type) {
    _currentTheme = type;
    switch (type) {
      case ThemeType.blue:
        _primaryColor = const Color(0xFF3374F6);
        _secondaryColor = const Color(0xFF4EAEF7);
        _tertiaryColor = const Color(0xFF76FBFD);
        _mutedColor = const Color(0xFF63A6D1);
        _backgroundColor = const Color(0xFFE3F2FD);
        _iconBgColor = const Color(0x334EAEF7);
        break;
      case ThemeType.green:
        _primaryColor = const Color(0xFF0A9765);
        _secondaryColor = const Color(0xFF2FC892);
        _tertiaryColor = const Color(0xFF5FF5C3); // Default for now
        _mutedColor = const Color(0xFF6FAF9B); // Default for now
        _backgroundColor = const Color(0xFFD5F4E9);
        _iconBgColor = const Color(0x332FC892);

        break;
      case ThemeType.orange:
        _primaryColor = const Color(0xFF8C4E1A);
        _secondaryColor = const Color(0xFFBC6C25);
        _tertiaryColor = const Color(0xFFF59E4C); // Default for now
        _mutedColor = const Color(0xFFA67C5B); // Default for now
        _backgroundColor = const Color(0xFFFEFADF);
        _iconBgColor = const Color(0x33BC6C25);
        break;
    }
    notifyListeners();
  }

  void setThemeByName(String themeName) {
    if (themeName.toLowerCase().contains('green')) {
      setTheme(ThemeType.green);
    } else if (themeName.toLowerCase().contains('orange')) {
      setTheme(ThemeType.orange);
    } else {
      setTheme(ThemeType.blue);
    }
  }

  void updateColors({
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? mutedColor,
    Color? backgroundColor,
  }) {
    if (primaryColor != null) _primaryColor = primaryColor;
    if (secondaryColor != null) _secondaryColor = secondaryColor;
    if (tertiaryColor != null) _tertiaryColor = tertiaryColor;
    if (mutedColor != null) _mutedColor = mutedColor;
    if (backgroundColor != null) _backgroundColor = backgroundColor;
    notifyListeners();
  }

  void updateThemeFromColorsList(List<dynamic> themeColors, String themeName) {
    setThemeByName(themeName);

    for (var colorObj in themeColors) {
      if (colorObj is Map<String, dynamic>) {
        final colorKey = colorObj['color_key'];
        final colorValue = colorObj['color_value'];
        if (colorKey != null && colorValue is String) {
          try {
            final color = _parseHex(colorValue);
            switch (colorKey) {
              case 'primary_color':
                _primaryColor = color;
                break;
              case 'secondary_color':
                _secondaryColor = color;
                break;
              case 'tertiary_color':
                _tertiaryColor = color;
                break;
              case 'muted_color':
                _mutedColor = color;
                break;
              case 'background_color':
                _backgroundColor = color;
                break;
              case 'icon_bg_color':
                _iconBgColor = color;
                break;
            }
          } catch (e) {
            print('Error parsing color $colorKey ($colorValue): $e');
          }
        }
      }
    }
    notifyListeners();
  }

  /// Updates colors using hex strings (e.g., "#3374F6")
  void updateFromHex({
    String? primaryHex,
    String? secondaryHex,
    String? tertiaryHex,
    String? mutedHex,
    String? backgroundHex,
    String? iconBgHex,
  }) {
    if (primaryHex != null) _primaryColor = _parseHex(primaryHex);
    if (secondaryHex != null) _secondaryColor = _parseHex(secondaryHex);
    if (tertiaryHex != null) _tertiaryColor = _parseHex(tertiaryHex);
    if (mutedHex != null) _mutedColor = _parseHex(mutedHex);
    if (backgroundHex != null) _backgroundColor = _parseHex(backgroundHex);
    if (iconBgHex != null) _iconBgColor = _parseHex(iconBgHex);
    notifyListeners();
  }

  Color _parseHex(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      print('Error parsing hex color $hex: $e');
      return Colors.transparent;
    }
  }
}