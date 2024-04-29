import 'dart:io';

import 'package:nian_common_utils/utils/loading_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../log_utils/app_log_utils.dart';
import '../log_utils/format_dio_logger/format_dio_logger.dart';
import 'response_handle.dart';

typedef NetSuccessCallback<T> = Function(T data);
typedef NetSuccessListCallback<T> = Function(List<T> data);
typedef NetErrorCallback = Function(int code, String msg);

// 枚举请求类型
enum DioMethod { get, post, put, patch, delete, head }

class DioUtil {
  /// 连接超时时间
  final Duration _connectTimeout = const Duration(seconds: 30);

  /// 响应超时时间
  final Duration _receiveTimeout = const Duration(seconds: 30);

  /// 发送超时时间
  final Duration _sendTimeout = const Duration(seconds: 6);

  static DioUtil? _instance;
  static Dio _dio = Dio();

  DioUtil.internal({String? baseUrl, List<Interceptor>? interceptor}) {
    _instance = this;
    _instance!._init(baseUrl, interceptor);
  }

  static DioUtil getInstance(
      {String? baseUrl, List<Interceptor>? interceptor}) {
    _instance ?? DioUtil.internal();
    return _instance!;
  }

  factory DioUtil() => _instance!;

  /// 取消请求token
  final CancelToken _cancelToken = CancelToken();

  String? proxyUrl = "";

  _init(String? baseUrl, List<Interceptor>? interceptor) {
    /// 初始化基本选项
    BaseOptions baseOptions = BaseOptions(
      baseUrl: baseUrl ?? "",
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      // contentType: Headers.formUrlEncodedContentType,
      contentType: "application/json",
    );

    // 实际请求基本选项
    // RequestOptions requestOptions = RequestOptions(
    //   baseUrl: baseUrl,
    //   connectTimeout: _connectTimeout,
    //   receiveTimeout: _receiveTimeout,
    //   sendTimeout: _sendTimeout,
    //   // contentType: Headers.formUrlEncodedContentType,
    //   contentType: "application/json",
    // );

    /// 初始化dio
    _dio = Dio(baseOptions);

    /// 添加拦截器
    /// 基础拦截器
    if (interceptor != null) {
      if (interceptor.isNotEmpty) {
        _dio.interceptors.addAll(interceptor);
      }
    }

    /// 打印日志
    _dio.interceptors.add(FormatDioLogger(
      requestHeader: false,
      maxBoxWidth: 1,
    ));

    /// 代理配置
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          // Proxy all request to localhost:8888.
          // Be aware, the proxy should went through you running device,
          // not the host platform.
          if (proxyUrl != "") {
            AppLog.i(
              LogMsg(
                'PROXY $proxyUrl',
                thread: "Request Proxy",
                method: "Proxy",
              ),
            );
            return 'PROXY $proxyUrl';
          }
          return 'DIRECT';
        };
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  Dio get dio => _dio;

  /// 请求类
  Future<BaseResponse> request<T>(
    String url, {
    DioMethod method = DioMethod.post,
    Map<String, dynamic>? params,
    data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    const methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.put: 'put',
      DioMethod.delete: 'delete',
      DioMethod.patch: 'patch',
      DioMethod.head: 'head',
    };

    options ??= Options(method: methodValues[method]);
    // 没有网络
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      var netError = {
        "code": CodeHandle.netError,
        "message": "没有网络了",
      };
      return BaseResponse.fromJson(netError, (json) => null);
    }
    Response? response;

    try {
      response = await _dio.request(
        url,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken ?? _cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      LoadingUtils.dismiss();
      if (e.type == DioExceptionType.unknown) {
        var jsonError = {
          "code": CodeHandle.unknownError,
          "message": e.error.toString(),
        };
        return BaseResponse.fromJson(jsonError, (json) => null);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        var jsonError = {
          "code": CodeHandle.receiveTimeoutError,
          "message": "请求超时",
        };
        return BaseResponse.fromJson(jsonError, (json) => null);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        var jsonError = {
          "code": CodeHandle.connectTimeoutError,
          "message": "连接超时",
        };
        return BaseResponse.fromJson(jsonError, (json) => null);
      } else if (e.type == DioExceptionType.badResponse) {
        var jsonError = {
          "code": CodeHandle.badResponse,
          "message": "返回出错",
        };
        return BaseResponse.fromJson(jsonError, (json) => null);
      }
      // rethrow;
    }
    return BaseResponse.fromJson(
        response != null ? response.data : {}, (json) => null);
  }

  Future<BaseResponse> requestNetwork<T>(
    String url, {
    DioMethod method = DioMethod.post,
    Map<String, dynamic>? params,
    data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    NetSuccessCallback<T?>? onSuccess,
    NetErrorCallback? onError,
  }) {
    return request(
      url,
      method: method,
      data: data,
      params: params,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    )..then<void>((BaseResponse result) {
        if (result.code == CodeHandle.success) {
          onSuccess?.call(result.data);
        } else {
          _onError(result.code, result.msg!, onError);
        }
      });
  }

  void _onError(int? code, String msg, NetErrorCallback? onError) {
    if (code == null) {
      code = CodeHandle.unknownError;
      msg = 'Unknown exception';
    }
    onError?.call(code, msg);
    AppLog.e('接口请求异常： code: $code, msg: $msg');
  }

  /// 取消网络请求
  void cancelRequests({CancelToken? token}) {
    token ?? _cancelToken.cancel("cancelled");
  }
}
