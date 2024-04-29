import 'dart:math';
import 'package:flutter/material.dart';

class ColorUtils {
  static Color color(String colorString) {
    return Color(intColor(colorString));
  }

  static int intColor(String? colorString) {
    if (colorString?.isEmpty ?? true) {
      throw ArgumentError('Unknown color');
    }
    if (colorString![0] == '#') {
      int? color = int.tryParse(colorString.substring(1), radix: 16);
      if (colorString.length == 7 && color != null) {
        // Set the alpha value
        color |= 0x00000000ff000000;
      } else if (colorString.length != 9) {
        throw ArgumentError('Unknown color');
      }
      return color!;
    } else {
      return intColor('#$colorString');
    }
  }

  /// 创建Material风格的color
  static MaterialColor materialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch as Map<int, Color>);
  }

  /// 取随机颜色
  static Color randomColor() {
    var red = Random.secure().nextInt(255);
    var greed = Random.secure().nextInt(255);
    var blue = Random.secure().nextInt(255);
    return Color.fromARGB(255, red, greed, blue);
  }

  /// 设置动态颜色
  static Color dynamicColor(BuildContext context, Color lightColor, [Color? darkColor]) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColor ?? lightColor : lightColor;
  }
}
