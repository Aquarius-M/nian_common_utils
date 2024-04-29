import 'dart:math';

class NumUtils {
  /// 获取随机整数（默认包含最大最小值）
  static int getRandomInt(int min, int max, {bool inclusiveMin = true, bool inclusiveMax = true}) {
    assert(min <= max, 'Min must be less than or equal to Max，Invalid arguments: min=$min, max=$max');
    int minVal = inclusiveMin ? min : min + 1;
    int maxVal = inclusiveMax ? max : max - 1;
    return minVal + Random.secure().nextInt(maxVal - minVal + 1);
  }

  /// 获取随机小数（默认包含最大最小值）
  static double getRandomDouble(double min, double max, {bool inclusiveMin = true, bool inclusiveMax = true}) {
    assert(min <= max, 'Min must be less than or equal to Max，Invalid arguments: min=$min, max=$max');
    double minVal = inclusiveMin ? min : min + 0.0000000001;
    double maxVal = inclusiveMax ? max : max - 0.0000000001;
    return minVal + Random.secure().nextDouble() * (maxVal - minVal);
  }

  /// 数量格式化
  static String numFormat(int num) {
    if (num > 999 && num <= 9999) {
      return "${roundingNum((num / 1000), 1)} k";
    } else if (num > 9999 && num <= 99999999) {
      return "${roundingNum((num / 10000), 1)} w";
    } else if (num > 99999999) {
      return "${roundingNum((num / 100000000), 1)} b";
    } else {
      return num.toString();
    }
  }

  /// 取消四舍五入
  /// ignore: unused_element
  static String roundingNum(double num, int fractionDigits) {
    if ((num.toString().length - num.toString().lastIndexOf(".") - 1) < fractionDigits) {
      //小数点后有几位小数
      return num.toStringAsFixed(fractionDigits).substring(0, num.toString().lastIndexOf(".") + fractionDigits + 1).toString();
    } else {
      return num.toString().substring(0, num.toString().lastIndexOf(".") + fractionDigits + 1).toString();
    }
  }
}
