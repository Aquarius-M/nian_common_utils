import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingUtils {
  static loading({EasyLoadingMaskType? maskType, bool? dismissOnTap}) {
    EasyLoading.show(
      maskType: maskType ?? EasyLoadingMaskType.black,
      dismissOnTap: dismissOnTap ?? false,
    );
  }

  static dismiss() {
    EasyLoading.dismiss();
  }
}
