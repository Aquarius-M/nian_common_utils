// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'toast_utils.dart';

class StringUtils {
  // 邮箱判断
  static bool isEmail(String input) {
    String regexEmail =
        "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$";
    if (input.isEmpty) return false;
    return RegExp(regexEmail).hasMatch(input);
  }

  // 纯数字
  static const String DIGIT_REGEX = "[0-9]+";
  static const String DIGIT_AND_PLUS_REGEX = r"[0-9+]+";

  // 含有数字
  static const String CONTAIN_DIGIT_REGEX = ".*[0-9].*";

  // 纯字母
  static const String LETTER_REGEX = "[a-zA-Z]+";

  // 包含字母
  static const String SMALL_CONTAIN_LETTER_REGEX = ".*[a-z].*";

  // 包含字母
  static const String BIG_CONTAIN_LETTER_REGEX = ".*[A-Z].*";

  // 包含字母
  static const String CONTAIN_LETTER_REGEX = ".*[a-zA-Z].*";

  // 纯中文
  static const String CHINESE_REGEX = "[\u4e00-\u9fa5]";

  // 仅仅包含字母和数字
  static const String LETTER_DIGIT_REGEX = "^[a-z0-9A-Z]+\$";
  static const String CHINESE_LETTER_REGEX = "([\u4e00-\u9fa5]+|[a-zA-Z]+)";
  static const String CHINESE_LETTER_DIGIT_REGEX =
      "^[a-z0-9A-Z\u4e00-\u9fa5]+\$";

  // 纯数字
  static bool isOnly(String input) {
    if (input.isEmpty) return false;
    return RegExp(DIGIT_REGEX).hasMatch(input);
  }

  // 纯数字
  static bool isDigitAndPlus(String? input) {
    if (input == null || input.isEmpty) return false;
    return RegExp(r'^-?[0-9+]+$').hasMatch(input);
  }

  // 含有数字
  static bool hasDigit(String input) {
    if (input.isEmpty) return false;
    return RegExp(CONTAIN_DIGIT_REGEX).hasMatch(input);
  }

  // 是否包含中文
  static bool isChinese(String input) {
    if (input.isEmpty) return false;
    return RegExp(CHINESE_REGEX).hasMatch(input);
  }

  // 随机数
  static int getRandom() {
    var rng = Random();
    return rng.nextInt(100);
  }

  // 计算文字宽高
  static Size boundingTextSize(
    String text,
    TextStyle style, {
    int maxLines = 2 ^ 31,
    double maxWidth = double.infinity,
  }) {
    if (text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: text,
        style: style,
      ),
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  /// 每隔 x位 加 pattern
  static String formatDigitPattern(String text,
      {int digit = 4, String pattern = ' '}) {
    text = text.replaceAllMapped(RegExp('(.{$digit})'), (Match match) {
      return '${match.group(0)}$pattern';
    });
    if (text.endsWith(pattern)) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  ///大陆手机号码11位数，匹配格式：前三位固定格式+后8位任意数
  /// 此方法中前三位格式有：
  /// 13+任意数 * 15+除4的任意数 * 18+除1和4的任意数 * 17+除9的任意数 * 147
  static bool checkPhone(String str) {
    return RegExp(
            '^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$')
        .hasMatch(str);
  }

  // 隐藏手机号
  static String hidePhone(String phone, int num) {
    final int length = phone.length;
    final int replaceLength = length - num;
    final String replacement =
        List<String>.generate((replaceLength / 4).ceil(), (int _) => '***')
            .join('');
    return phone.replaceRange(0, replaceLength, replacement);
  }

  // 隐藏邮箱
  static String hideEmail(String email, int num) {
    final int length = email.length;
    final int replaceLength = length - num;
    final String replacement =
        List<String>.generate((replaceLength / 4).ceil(), (int _) => '***')
            .join('');
    return email.replaceRange(num, length, replacement);
  }

  // 点击复制
  static void copy(String? text) {
    Clipboard.setData(ClipboardData(text: text!));
    ToastUtils.toast(msg: "已复制");
  }
}
