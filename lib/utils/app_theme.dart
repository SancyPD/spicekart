import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  static final AppTheme _instance = AppTheme._internal();
  static AppTheme get instance => _instance;

  AppTheme._internal();

  Color _primaryDeepBlue = const Color(0xFF3374F6);
  Color _secondaryLightBlue = const Color(0xFF4EAEF7);
  Color _tertiaryCyan = const Color(0xFF76FBFD);
  Color _mutedBlue = const Color(0xFF63A6D1);
  Color _lightBlueBg = const Color(0xFFE3F2FD);

  Color get primaryDeepBlue => _primaryDeepBlue;
  Color get secondaryLightBlue => _secondaryLightBlue;
  Color get tertiaryCyan => _tertiaryCyan;
  Color get mutedBlue => _mutedBlue;
  Color get lightBlueBg => _lightBlueBg;




  void updateColors({
    Color? primaryDeepBlue,
    Color? secondaryLightBlue,
    Color? tertiaryCyan,
    Color? mutedBlue,
    Color? lightBlueBg,
  }) {
    if (primaryDeepBlue != null) _primaryDeepBlue = primaryDeepBlue;
    if (secondaryLightBlue != null) _secondaryLightBlue = secondaryLightBlue;
    if (tertiaryCyan != null) _tertiaryCyan = tertiaryCyan;
    if (mutedBlue != null) _mutedBlue = mutedBlue;
    if (lightBlueBg != null) _lightBlueBg = lightBlueBg;
    notifyListeners();
  }

  /// Updates colors using hex strings (e.g., "#3374F6")
  void updateFromHex({
    String? primaryDeepBlueHex,
    String? secondaryLightBlueHex,
    String? tertiaryCyanHex,
    String? mutedBlueHex,
  }) {
    if (primaryDeepBlueHex != null) _primaryDeepBlue = _parseHex(primaryDeepBlueHex);
    if (secondaryLightBlueHex != null) _secondaryLightBlue = _parseHex(secondaryLightBlueHex);
    if (tertiaryCyanHex != null) _tertiaryCyan = _parseHex(tertiaryCyanHex);
    if (mutedBlueHex != null) _mutedBlue = _parseHex(mutedBlueHex);
    notifyListeners();
  }

  Color _parseHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
