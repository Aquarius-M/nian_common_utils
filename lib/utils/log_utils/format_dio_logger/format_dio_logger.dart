import 'package:dio/dio.dart';
import 'pretty_util.dart';

import 'constants.dart';

/// dio打印
class FormatDioLogger extends Interceptor {
  FormatDioLogger({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseBody = true,
    this.responseHeader = false,
    this.maxBoxWidth = kMaxWidth,
    this.error = true,
  }) {
    _prettyUtil = PrettyUtil(maxBoxWidth);
  }

  /// 打印请求，如果此字段为false，则[requestHeader]和[requestBody]也不会打印
  bool request;

  /// 打印请求头 [Options.headers]
  bool requestHeader;

  /// 打印请求参数 [Options.data]
  bool requestBody;

  /// 打印响应 [Response.data]，如果此字段为false，则[responseHeader]也不会打印
  bool responseBody;

  /// 打印响应头部 [Response.headers]
  bool responseHeader;

  /// 打印错误信息
  bool error;

  /// 盒子宽度大小，不影响数据的输出长度
  final int maxBoxWidth;

  late PrettyUtil _prettyUtil;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (request) {
      List<String> buffer = [];
      buffer.addAll(_prettyUtil.prettyBoxHeader(
          header: 'Request ║ ${options.method} ╠',
          url: options.uri.toString()));
      if (requestHeader) {
        buffer.add(_prettyUtil.prettySubHeader("Header"));
        final requestHeaders = <String, dynamic>{};
        requestHeaders.addAll(options.headers);
        requestHeaders['responseType'] = options.responseType.toString();
        requestHeaders['followRedirects'] = options.followRedirects;
        buffer.addAll(_prettyUtil.prettyMap(requestHeaders));
      }
      if (requestBody) {
        if (options.queryParameters.isNotEmpty) {
          buffer.add(_prettyUtil.prettySubHeader("Query Parameters"));
          buffer.addAll(_prettyUtil.prettyToStr(options.queryParameters));
        }
        if (options.data != null) {
          buffer.add(_prettyUtil.prettySubHeader("Body Data"));
          final dynamic data = options.data;
          if (data is FormData) {
            final formDataMap = <String, dynamic>{}
              ..addEntries(data.fields)
              ..addEntries(data.files);
            buffer.addAll(_prettyUtil.prettyMap(formDataMap));
          } else {
            buffer.addAll(_prettyUtil.prettyToStr(data));
          }
        }
      }
      _prettyUtil.log(buffer);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    List<String> buffer = [];
    buffer.addAll(_prettyUtil.prettyBoxHeader(
      header:
          "Response ║ ${response.requestOptions.method}-${response.statusCode} ${response.statusMessage} ╠",
      url: response.requestOptions.uri.toString(),
    ));
    if (responseHeader) {
      buffer.add(_prettyUtil.prettySubHeader("Header"));
      final responseHeaders = <String, String>{};
      response.headers
          .forEach((k, list) => responseHeaders[k] = list.toString());
      buffer.addAll(_prettyUtil.prettyMap(responseHeaders));
    }
    if (responseBody) {
      buffer.add(_prettyUtil.prettySubHeader("Body"));
      buffer.addAll(_prettyUtil.prettyToStr(response.data));
    }
    _prettyUtil.log(buffer);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      List<String> buffer = [];
      buffer.addAll(_prettyUtil.prettyBoxHeader(
        header:
            "Error ║ code: [${err.response?.statusCode}] message: [${err.response?.statusMessage}] ╠",
        url: err.requestOptions.uri.toString(),
      ));
      buffer.add(_prettyUtil.prettySubHeader("Detail"));
      buffer
          .addAll(_prettyUtil.prettyMap({"type": err.type, "msg": err.error}));
      if (err.response != null) {
        buffer.add(_prettyUtil.prettySubHeader("Error Body"));
        buffer.addAll(_prettyUtil.prettyToStr(err.response));
      }
      _prettyUtil.log(buffer, colorStr: errorColor);
    }
    super.onError(err, handler);
  }
}
