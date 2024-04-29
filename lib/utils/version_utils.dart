import 'package:url_launcher/url_launcher.dart';
import 'log_utils/app_log_utils.dart';

class VersionUtils {
  /// 跳转AppStore
  static Future<void> jumpAppStore({String? url}) async {
    // 这是微信的地址，到时候换成自己的应用的地址
    final tempURL = url ?? '';
    final Uri uri = Uri.parse(tempURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppLog.i("跳转失败！");
    }
  }

  /// 版本比较，是否有新版本
  /// appVersion：项目当前版本
  /// version：要比较的版本(比如最新版本)
  static bool hasNewVersion(String appVersion, String version) {
    // print(appVersion.compareTo(version)); // 字符串 比较大小, 0:相同、1:大于、-1:小于
    return appVersion.compareTo(version) < 0 ? true : false;
  }
}
