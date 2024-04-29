// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastTime {
  /// Show Short toast for 1 sec
  LENGTH_SHORT,

  /// Show Long toast for 5 sec
  LENGTH_LONG
}

enum ToastPosition {
  TOP,
  BOTTOM,
  CENTER,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
  CENTER_LEFT,
  CENTER_RIGHT,
  SNACKBAR,
  NONE,
}

var positionValue = {
  ToastPosition.TOP: ToastGravity.TOP,
  ToastPosition.BOTTOM: ToastGravity.BOTTOM,
  ToastPosition.CENTER: ToastGravity.CENTER,
  ToastPosition.TOP_LEFT: ToastGravity.TOP_LEFT,
  ToastPosition.TOP_RIGHT: ToastGravity.TOP_RIGHT,
  ToastPosition.BOTTOM_LEFT: ToastGravity.BOTTOM_LEFT,
  ToastPosition.CENTER_LEFT: ToastGravity.CENTER_LEFT,
  ToastPosition.CENTER_RIGHT: ToastGravity.CENTER_RIGHT,
  ToastPosition.SNACKBAR: ToastGravity.SNACKBAR,
  ToastPosition.NONE: ToastGravity.NONE,
};

var timeValue = {
  ToastTime.LENGTH_SHORT: Toast.LENGTH_SHORT,
  ToastTime.LENGTH_LONG: Toast.LENGTH_LONG,
};

class ToastUtils {
  static toast({
    required String msg,
    ToastPosition? position,
    ToastTime? time,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: timeValue[time ?? ToastTime.LENGTH_SHORT],
      gravity: positionValue[position ?? ToastPosition.CENTER],
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.8),
      textColor: textColor ?? Colors.white,
      fontSize: fontSize ?? 14.0,
    );
  }
}
