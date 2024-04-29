import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'log_utils/app_log_utils.dart';

class NetWorkUtils {
  static String netType = 'Unknown';

  /// 判断网络是否连接
  static Future<bool> isConnected() async {
    var connectResult = await (Connectivity().checkConnectivity());
    return connectResult.isNotEmpty;
  }

  /// 获取联网类型
  static Future<String> getConnectType() async {
    var connectResult = await (Connectivity().checkConnectivity());

    if (connectResult[0] == ConnectivityResult.mobile) {
      netType = "流量";
    } else if (connectResult[0] == ConnectivityResult.wifi) {
      netType = "WIFI";
    } else {
      netType = "未连接";
    }
    return netType;
  }

  static StreamSubscription<List<ConnectivityResult>> connectivitySubscription =
      Connectivity().onConnectivityChanged.listen((result) {
    if (result[0] == ConnectivityResult.mobile) {
      netType = "流量";
    } else if (result[0] == ConnectivityResult.wifi) {
      netType = "WIFI";
    } else {
      netType = "未连接";
    }
    AppLog.wtf("网络连接已改变:$netType");
  });

  static cancel() {
    connectivitySubscription.cancel();
  }
}
