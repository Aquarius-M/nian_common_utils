// ignore_for_file: constant_identifier_names

enum DateFormat {
  DEFAULT, //yyyy-MM-dd HH:mm:ss.SSS
  NORMAL, //yyyy-MM-dd HH:mm:ss
  YEAR_MONTH_DAY_HOUR_MINUTE, //yyyy-MM-dd HH:mm
  YEAR_MONTH_DAY, //yyyy-MM-dd
  YEAR_MONTH, //yyyy-MM
  YEAR, //yyyy
  MONTH, //MM
  DAY, //dd
  MONTH_DAY, //MM-dd
  MONTH_DAY_HOUR_MINUTE, //MM-dd HH:mm
  HOUR_MINUTE_SECOND, //HH:mm:ss
  HOUR_MINUTE, //HH:mm

  ZH_DEFAULT, //yyyy年MM月dd日 HH时mm分ss秒SSS毫秒
  ZH_NORMAL, //yyyy年MM月dd日 HH时mm分ss秒  /  timeSeparate: ":" --> yyyy年MM月dd日 HH:mm:ss
  ZH_YEAR_MONTH_DAY_HOUR_MINUTE, //yyyy年MM月dd日 HH时mm分  /  timeSeparate: ":" --> yyyy年MM月dd日 HH:mm
  ZH_YEAR_MONTH_DAY, //yyyy年MM月dd日
  ZH_YEAR_MONTH, //yyyy年MM月
  ZH_MONTH_DAY, //MM月dd日
  ZH_MONTH_DAY_HOUR_MINUTE, //MM月dd日 HH时mm分  /  timeSeparate: ":" --> MM月dd日 HH:mm
  ZH_HOUR_MINUTE_SECOND, //HH时mm分ss秒
  ZH_HOUR_MINUTE, //HH时mm分
}

///month->days.
Map<int, int> monthDay = {
  1: 31,
  2: 28,
  3: 31,
  4: 30,
  5: 31,
  6: 30,
  7: 31,
  8: 31,
  9: 30,
  10: 31,
  11: 30,
  12: 31,
};

class TimeUtils {
  /// 获取时间戳,为空时为当前时间戳
  static int getNowTimeStamp(DateTime? date) {
    int? result;
    if (date != null) {
      result = date.millisecondsSinceEpoch;
    } else {
      result = DateTime.now().millisecondsSinceEpoch;
    }
    return result;
  }

  /// 获取时间,为空时为当前时间 (默认为yyyy-MM-dd HH:mm:ss)
  static String? getNowTime(DateTime? date) {
    DateTime? result;
    if (date != null) {
      result = date;
    } else {
      result = DateTime.now();
    }
    return getTime(dateTime: result);
  }

  /// 将字符串或者时间戳转化成DateTime
  static DateTime getDateTime({String? dateStr, int? milliseconds}) {
    DateTime? dateTime;
    if (dateStr != null) {
      dateTime = DateTime.tryParse(dateStr);
      return dateTime!;
    }
    if (milliseconds != null) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      return dateTime;
    }
    return dateTime!;
  }

  /// DateTime或者时间戳转字符串
  static String? getTime({
    DateTime? dateTime,
    int? milliseconds,
    DateFormat format = DateFormat.NORMAL,
    String? dateSeparate,
    String? timeSeparate,
    bool? isZh = false,
  }) {
    String? result;
    if (dateTime == null && milliseconds == null) {
      String dateStr = DateTime.now().toString();
      result = formatDateTime(dateStr, format, dateSeparate, timeSeparate, isZh);
    }
    if (dateTime != null) {
      String dateStr = dateTime.toString();
      result = formatDateTime(dateStr, format, dateSeparate, timeSeparate, isZh);
      return result;
    }
    if (milliseconds != null) {
      if (milliseconds == 0) {
        result = "";
      }
      DateTime dateTime = getDateTime(milliseconds: milliseconds);
      result = getTime(
        dateTime: dateTime,
        format: format,
        dateSeparate: dateSeparate,
        timeSeparate: timeSeparate,
      );
    }
    return result;
  }

  /// 是否为闰年
  static bool isLeapYearByYear(int year) {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }

  /// 在今年的第几天
  static int getDayOfYear(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int days = dateTime.day;
    for (int i = 1; i < month; i++) {
      days = days + (monthDay[i] as int);
    }
    if (isLeapYearByYear(year) && month > 2) {
      days = days + 1;
    }
    return days;
  }

  /// 是否同年
  static bool yearIsEqual(DateTime dateTime, DateTime locDateTime) {
    return dateTime.year == locDateTime.year;
  }

  /// 是否同年同月
  static bool yearAndMonthIsEqual(DateTime dateTime, DateTime locDateTime) {
    return dateTime.year == locDateTime.year && dateTime.month == locDateTime.month;
  }

  ///是否为今天.
  static bool isToday(DateTime dateTime) {
    return dateTime.day == DateTime.now().day;
  }

  ///是否是昨天.
  static bool isYesterday(DateTime dateTime, DateTime locDateTime) {
    if (yearIsEqual(dateTime, locDateTime)) {
      int spDay = getDayOfYear(locDateTime) - getDayOfYear(dateTime);
      return spDay == 1;
    } else {
      return ((locDateTime.year - dateTime.year == 1) && dateTime.month == 12 && locDateTime.month == 1 && dateTime.day == 31 && locDateTime.day == 1);
    }
  }

  /// 持续时间(m)
  static String getDurationFromMinutess(int minutes) {
    final duration = Duration(minutes: minutes);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitHours:$twoDigitMinutes";
  }

  /// 持续时间(h)
  static String getDurationFromHour(int sec) {
    var duration = Duration(seconds: sec);
    var microseconds = duration.inMicroseconds;
    if (microseconds < 0) {
      return '';
    }

    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);

    if (microseconds < 0) microseconds = -microseconds;

    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);
    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);
    return "${hours.abs() > 0 ? '${hours.abs()}小时' : ''}"
        "${minutes > 0 ? '$minutes分' : ''}"
        "${seconds > 0 ? '$seconds秒' : ''}";
  }

  static String formatDateTime(String time, DateFormat format, String? dateSeparate, String? timeSeparate, bool? isZH) {
    if (isZH!) {
      time = convertToZHDateTimeString(time, timeSeparate);
    }
    switch (format) {
      case DateFormat.NORMAL: //yyyy-MM-dd HH:mm:ss
        time = time.substring(0, "yyyy-MM-dd HH:mm:ss".length);
        break;
      case DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE: //yyyy-MM-dd HH:mm
        time = time.substring(0, "yyyy-MM-dd HH:mm".length);
        break;
      case DateFormat.YEAR_MONTH_DAY: //yyyy-MM-dd
        time = time.substring(0, "yyyy-MM-dd".length);
        break;
      case DateFormat.YEAR_MONTH: //yyyy-MM
        time = time.substring(0, "yyyy-MM".length);
        break;
      case DateFormat.YEAR: //yyyy
        time = time.substring(0, "yyyy".length);
        break;
      case DateFormat.MONTH: //yyyy
        time = time.substring(0, "MM".length);
        break;
      case DateFormat.DAY: //yyyy
        time = time.substring(0, "dd".length);
        break;
      case DateFormat.MONTH_DAY: //MM-dd
        time = time.substring("yyyy-".length, "yyyy-MM-dd".length);
        break;
      case DateFormat.MONTH_DAY_HOUR_MINUTE: //MM-dd HH:mm
        time = time.substring("yyyy-".length, "yyyy-MM-dd HH:mm".length);
        break;
      case DateFormat.HOUR_MINUTE_SECOND: //HH:mm:ss
        time = time.substring("yyyy-MM-dd ".length, "yyyy-MM-dd HH:mm:ss".length);
        break;
      case DateFormat.HOUR_MINUTE: //HH:mm
        time = time.substring("yyyy-MM-dd ".length, "yyyy-MM-dd HH:mm".length);
        break;
      case DateFormat.ZH_NORMAL: //yyyy年MM月dd日 HH时mm分ss秒
        time = time.substring(0, "yyyy年MM月dd日 HH时mm分ss秒".length - (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_YEAR_MONTH_DAY_HOUR_MINUTE: //yyyy年MM月dd日 HH时mm分
        time = time.substring(0, "yyyy年MM月dd日 HH时mm分".length - (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_YEAR_MONTH_DAY: //yyyy年MM月dd日
        time = time.substring(0, "yyyy年MM月dd日".length);
        break;
      case DateFormat.ZH_YEAR_MONTH: //yyyy年MM月
        time = time.substring(0, "yyyy年MM月".length);
        break;
      case DateFormat.ZH_MONTH_DAY: //MM月dd日
        time = time.substring("yyyy年".length, "yyyy年MM月dd日".length);
        break;
      case DateFormat.ZH_MONTH_DAY_HOUR_MINUTE: //MM月dd日 HH时mm分
        time = time.substring("yyyy年".length, "yyyy年MM月dd日 HH时mm分".length - (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_HOUR_MINUTE_SECOND: //HH时mm分ss秒
        time = time.substring("yyyy年MM月dd日 ".length, "yyyy年MM月dd日 HH时mm分ss秒".length - (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_HOUR_MINUTE: //HH时mm分
        time = time.substring("yyyy年MM月dd日 ".length, "yyyy年MM月dd日 HH时mm分".length - (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      default:
        break;
    }
    time = dateTimeSeparate(time, dateSeparate, timeSeparate);
    return time;
  }

  ///分隔符转换.
  static String dateTimeSeparate(String time, String? dateSeparate, String? timeSeparate) {
    if (dateSeparate != null) {
      time = time.replaceAll("-", dateSeparate);
    }
    if (timeSeparate != null) {
      time = time.replaceAll(":", timeSeparate);
    }
    return time;
  }

  static String convertToZHDateTimeString(String time, String? timeSeparate) {
    time = time.replaceFirst("-", "年");
    time = time.replaceFirst("-", "月");
    time = time.replaceFirst(" ", "日 ");
    if (timeSeparate == null || timeSeparate.isEmpty) {
      time = time.replaceFirst(":", "时");
      time = time.replaceFirst(":", "分");
      time = time.replaceFirst(".", "秒");
      time = "$time毫秒";
    } else {
      time = time.replaceAll(":", timeSeparate);
    }
    return time;
  }

  // 相差几天
  static int calculateDateDiff(DateTime startDate, DateTime endDate) {
    Duration diff = endDate.difference(startDate);
    return diff.inDays;
  }

  static String getAge(DateTime brt) {
    int age = 0;
    DateTime dateTime = getDateTime(milliseconds: DateTime.now().millisecondsSinceEpoch);
    if (dateTime.isBefore(brt)) {
      //出生日期晚于当前时间，无法计算
      return '未知';
    }
    int yearNow = dateTime.year; //当前年份
    int monthNow = dateTime.month; //当前月份
    int dayOfMonthNow = dateTime.day; //当前日期

    int yearBirth = brt.year;
    int monthBirth = brt.month;
    int dayOfMonthBirth = brt.day;
    age = yearNow - yearBirth; //计算整岁数
    if (monthNow <= monthBirth) {
      if (monthNow == monthBirth) {
        if (dayOfMonthNow < dayOfMonthBirth) age--; //当前日期在生日之前，年龄减一
      } else {
        age--; //当前月份在生日之前，年龄减一
      }
    }
    return "$age";
  }

  static String getConstellation(DateTime birthday) {
    const String capricorn = '摩羯座'; //Capricorn 摩羯座（12月22日～1月20日）
    const String aquarius = '水瓶座'; //Aquarius 水瓶座（1月21日～2月19日）
    const String pisces = '双鱼座'; //Pisces 双鱼座（2月20日～3月20日）
    const String aries = '白羊座'; //aries 白羊座 (3月21日～4月20日)
    const String taurus = '金牛座'; //Taurus 金牛座 (4月21～5月21日)
    const String gemini = '双子座'; //Gemini 双子座 (5月22日～6月21日)
    const String cancer = '巨蟹座'; //Cancer 巨蟹座（6月22日～7月22日）
    const String leo = '狮子座'; //Leo 狮子座（7月23日～8月23日）
    const String virgo = '处女座'; //Virgo 处女座（8月24日～9月23日）
    const String libra = '天秤座'; //Libra 天秤座（9月24日～10月23日）
    const String scorpio = '天蝎座'; //Scorpio 天蝎座（10月24日～11月22日）
    const String sagittarius = '射手座'; //Sagittarius 射手座（11月23日～12月21日）

    int month = birthday.month;
    int day = birthday.day;
    String constellation = '';

    switch (month) {
      case DateTime.january:
        constellation = day < 21 ? capricorn : aquarius;
        break;
      case DateTime.february:
        constellation = day < 20 ? aquarius : pisces;
        break;
      case DateTime.march:
        constellation = day < 21 ? pisces : aries;
        break;
      case DateTime.april:
        constellation = day < 21 ? aries : taurus;
        break;
      case DateTime.may:
        constellation = day < 22 ? taurus : gemini;
        break;
      case DateTime.june:
        constellation = day < 22 ? gemini : cancer;
        break;
      case DateTime.july:
        constellation = day < 23 ? cancer : leo;
        break;
      case DateTime.august:
        constellation = day < 24 ? leo : virgo;
        break;
      case DateTime.september:
        constellation = day < 24 ? virgo : libra;
        break;
      case DateTime.october:
        constellation = day < 24 ? libra : scorpio;
        break;
      case DateTime.november:
        constellation = day < 23 ? scorpio : sagittarius;
        break;
      case DateTime.december:
        constellation = day < 22 ? sagittarius : capricorn;
        break;
    }

    return constellation;
  }
}
