import 'dart:io';
import 'package:nian_common_utils/utils/time_utils.dart';
import 'package:get_server/get_server.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// app日志
/// 建议使用日志模板，如: LogMsg('xxx', tag: 'xx', method: 'xxx.xxx')

class AppLog {
  static String outPath = '';

  static bool isDebug = true;

  static Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      lineLength: 1,
    ),
  );

  /// 文件流
  static IOSink? _sink;

  /// 初始化日志，处理本地存储日志
  static init() async {
    var outPath = await _outPath;
    _createFileSink();
    GetServer(
      port: 8002,
      home: FolderWidget(
        outPath,
        allowDirectoryListing: true,
      ),
    );
  }

  /// 创建文件流
  static Future<void> _createFileSink() async {
    /// 初始化文件流
    var logFile = await _logFile;
    _sink = logFile.openWrite(mode: FileMode.append);
  }

  /// 获取日志文件名称
  static String get fileName {
    return '.$_fileName';
  }

  /// 日志文件
  static Future<File> get _logFile async {
    String outDir = await _outPath;
    File file = File('$outDir/.$_fileName');
    if (!await file.exists()) {
      return await file.create(recursive: true);
    }
    return file;
  }

  /// 日志文件
  static String get _fileName {
    return '${DateTime.now().toString().replaceAll(RegExp(r'(?<=\d\d-\d\d-\d\d)[\S|\s]+'), '')}.log';
  }

  /// 日志输出路径
  static Future<String> get _outPath async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    if (outPath.isEmpty) {
      outPath = '${appDocDir.path}/log';
    }
    return '${appDocDir.path}/log';
  }

  /// 清理日志
  static Future<void> clean() async {
    // 删除已创建的日志文件
    _sink?.close();
    var logFile = await _logFile;
    await logFile.delete();
    // 生成新的日志文件
    _createFileSink();
  }

  static void d(dynamic message) {
    _sink?.writeln('[${TimeUtils.getTime(dateTime: DateTime.now())}]$message');
    if (isDebug) {
      logger.d(message);
    }
  }

  static void e(dynamic message) {
    _sink?.writeln('[${TimeUtils.getTime(dateTime: DateTime.now())}]$message');
    if (isDebug) {
      logger.e(message);
    }
  }

  static void v(dynamic message) {
    _sink?.writeln('[${TimeUtils.getTime(dateTime: DateTime.now())}]$message');
    if (isDebug) {
      logger.t(message);
    }
  }

  static void i(dynamic message) {
    _sink?.writeln('[${TimeUtils.getTime(dateTime: DateTime.now())}]$message');
    if (isDebug) {
      logger.i(message);
    }
  }

  static void w(dynamic message) {
    _sink?.writeln('[${TimeUtils.getTime(dateTime: DateTime.now())}]$message');
    if (isDebug) {
      logger.w(message);
    }
  }

  static void wtf(dynamic message) {
    _sink?.writeln('[${TimeUtils.getTime(dateTime: DateTime.now())}]$message');
    if (isDebug) {
      logger.f(message);
    }
  }

  static void writeFile(dynamic message) {
    _sink?.writeln('[${TimeUtils.getTime(dateTime: DateTime.now())}]$message');
  }
}

/// 默认日志信息模板
class LogMsg {
  /// 所属线程
  final String thread;

  /// 标签
  final String tag;

  /// 所属方法
  final String method;

  /// 日志信息
  final dynamic msg;
  LogMsg(
    this.msg, {
    this.thread = 'main',
    this.tag = 'none',
    this.method = '',
  });

  @override
  String toString() {
    return 'LogMsg: [thread:$thread][tag:$tag][method:$method]$msg';
  }
}
