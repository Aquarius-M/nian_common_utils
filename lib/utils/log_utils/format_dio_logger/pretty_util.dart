import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../app_log_utils.dart';
import 'constants.dart';

///
class PrettyUtil {
  PrettyUtil(this.maxBoxWidth);

  /// 盒子宽度
  final int maxBoxWidth;

  /// 格式化盒子头部
  /// [header] 头部内容
  /// [url] api地址
  List<String> prettyBoxHeader({
    required String header,
    required String url,
  }) {
    header = '$leftTopLine╣ $header';
    return [
      '$header${hLine * (maxBoxWidth - header.length)}╗',
      '$leftLine  $url',
    ];
  }

  /// 格式化副标题
  String prettySubHeader(String text) {
    text = '$subLine$hLine $text ';
    return "$text${dashedLine * (maxBoxWidth - text.length)}";
  }

  /// 格式化map
  List<String> prettyMap(Map<String, dynamic>? map) {
    if (map?.isEmpty ?? true) return [];
    var list = <String>[];
    map?.forEach((key, value) {
      list.add("$leftLine $key: ${value.toString()}");
    });
    return list;
  }

  /// 美化为格式化字符串
  /// 未避免影响数据格式的美观，不对长数据进行超限换行处理
  List<String> prettyToStr(dynamic message) {
    return _pretty(message).split("\n").map((e) => "$leftLine$e").toList();
  }

  /// 格式化足部
  String _prettyFooter() {
    return '$leftBottomLine${'═' * (maxBoxWidth - 1)}$rightBottomLine';
  }

  /// 美化颜色并输出数据
  void log(List<String> list, {String? colorStr}) {
    list.add(_prettyFooter());
    for (var element in list) {
      if (colorStr != null) {
        _print("$colorStr$element\x1b[0m");
      } else {
        _print(element);
      }
      AppLog.writeFile(element);
    }
  }

  /// 格式化
  String _pretty(dynamic message) {
    try {
      final finalMessage = message is String ? jsonDecode(message) : message;
      if (finalMessage is Map || finalMessage is Iterable) {
        var spaces = ' ' * 4;
        var encoder = JsonEncoder.withIndent(spaces, (msg) => msg.toString());
        return encoder.convert(finalMessage);
      } else {
        return finalMessage.toString();
      }
    } catch (e) {
      _print("格式化错误===> ${e.toString()}");
      return message.toString();
    }
  }

  void _print(String msg) {
    if (kDebugMode) {
      print(msg);
    }
  }
}
