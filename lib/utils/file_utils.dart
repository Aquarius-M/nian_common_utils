import 'package:mime/mime.dart';

class FileUtils {
  /// 源文件地址
  final String path;

  FileUtils(this.path);

  /// 目录路径
  String get dirPath {
    return path.substring(0, path.lastIndexOf('/'));
  }

  /// 扩展名
  String get ext {
    return path.substring(path.lastIndexOf('.') + 1);
  }

  /// 文件名
  String get name {
    return path.substring(path.lastIndexOf('/') + 1);
  }

  /// mime信息
  String? get mime {
    return lookupMimeType(path);
  }

  /// 是否图片
  bool get isImage {
    return RegExp(r'^image').hasMatch(mime ?? '');
  }

  /// 是否视频
  bool get isVideo {
    return RegExp(r'^video').hasMatch(mime ?? '');
  }
}
