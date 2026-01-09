import 'package:flutter/material.dart';

enum ChatThemeType {
  classic,
  ocean,
  sunset,
  forest,
  lavender,
  midnight,
}

class ChatTheme {
  final String name;
  final ChatThemeType type;
  final LinearGradient backgroundGradient;
  final Color myMessageColor;
  final Color theirMessageColor;
  final Color myMessageTextColor;
  final Color theirMessageTextColor;
  final Color timestampColor;
  final Color inputBackgroundColor;
  final Color inputBorderColor;

  const ChatTheme({
    required this.name,
    required this.type,
    required this.backgroundGradient,
    required this.myMessageColor,
    required this.theirMessageColor,
    required this.myMessageTextColor,
    required this.theirMessageTextColor,
    required this.timestampColor,
    required this.inputBackgroundColor,
    required this.inputBorderColor,
  });

  static const ChatTheme classic = ChatTheme(
    name: 'Classic',
    type: ChatThemeType.classic,
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF020617), Color(0xFF0A2540)],
    ),
    myMessageColor: Color(0xFF38BDF8),
    theirMessageColor: Color(0xFF0B1220),
    myMessageTextColor: Colors.white,
    theirMessageTextColor: Colors.white,
    timestampColor: Color(0x99FFFFFF),
    inputBackgroundColor: Color(0x0DFFFFFF),
    inputBorderColor: Color(0x1AFFFFFF),
  );

  static const ChatTheme ocean = ChatTheme(
    name: 'Ocean',
    type: ChatThemeType.ocean,
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A4D68), Color(0xFF05161A)],
    ),
    myMessageColor: Color(0xFF088395),
    theirMessageColor: Color(0xFF0B2027),
    myMessageTextColor: Colors.white,
    theirMessageTextColor: Color(0xFFE1F7F5),
    timestampColor: Color(0x99FFFFFF),
    inputBackgroundColor: Color(0x1AFFFFFF),
    inputBorderColor: Color(0x33FFFFFF),
  );

  static const ChatTheme sunset = ChatTheme(
    name: 'Sunset',
    type: ChatThemeType.sunset,
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A0B2E), Color(0xFF3D1E6D)],
    ),
    myMessageColor: Color(0xFFFF6B6B),
    theirMessageColor: Color(0xFF2A1A4E),
    myMessageTextColor: Colors.white,
    theirMessageTextColor: Color(0xFFFFE5EC),
    timestampColor: Color(0x99FFFFFF),
    inputBackgroundColor: Color(0x1AFFFFFF),
    inputBorderColor: Color(0x33FFFFFF),
  );

  static const ChatTheme forest = ChatTheme(
    name: 'Forest',
    type: ChatThemeType.forest,
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D2818), Color(0xFF04471C)],
    ),
    myMessageColor: Color(0xFF16C172),
    theirMessageColor: Color(0xFF0A2114),
    myMessageTextColor: Colors.white,
    theirMessageTextColor: Color(0xFFE8F5E9),
    timestampColor: Color(0x99FFFFFF),
    inputBackgroundColor: Color(0x1AFFFFFF),
    inputBorderColor: Color(0x33FFFFFF),
  );

  static const ChatTheme lavender = ChatTheme(
    name: 'Lavender',
    type: ChatThemeType.lavender,
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2D1B69), Color(0xFF1A0B3F)],
    ),
    myMessageColor: Color(0xFF9D84B7),
    theirMessageColor: Color(0xFF251553),
    myMessageTextColor: Colors.white,
    theirMessageTextColor: Color(0xFFF3E5F5),
    timestampColor: Color(0x99FFFFFF),
    inputBackgroundColor: Color(0x1AFFFFFF),
    inputBorderColor: Color(0x33FFFFFF),
  );

  static const ChatTheme midnight = ChatTheme(
    name: 'Midnight',
    type: ChatThemeType.midnight,
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF000000), Color(0xFF1C1C1E)],
    ),
    myMessageColor: Color(0xFF0A84FF),
    theirMessageColor: Color(0xFF1C1C1E),
    myMessageTextColor: Colors.white,
    theirMessageTextColor: Colors.white,
    timestampColor: Color(0x99FFFFFF),
    inputBackgroundColor: Color(0x1AFFFFFF),
    inputBorderColor: Color(0x33FFFFFF),
  );

  static List<ChatTheme> get allThemes => [
        classic,
        ocean,
        sunset,
        forest,
        lavender,
        midnight,
      ];

  static ChatTheme fromType(ChatThemeType type) {
    return allThemes.firstWhere((theme) => theme.type == type);
  }

  static ChatThemeType typeFromString(String? value) {
    if (value == null) return ChatThemeType.classic;
    return ChatThemeType.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => ChatThemeType.classic,
    );
  }
}
