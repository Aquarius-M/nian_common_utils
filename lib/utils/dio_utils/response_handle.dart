class CodeHandle {
  static const int success = 200; // 请求成功的状态码
  static const int successNotContent = 204;
  static const int notModified = 304;
  static const int forbidden = 403;
  static const int notFound = 404;

  static const int parseError = 1001;
  static const int socketError = 1002;
  static const int httpError = 1003;
  static const int connectTimeoutError = 1004;
  static const int sendTimeoutError = 1005;
  static const int receiveTimeoutError = 1006;
  static const int cancelError = 1007;
  static const int netError = 9997;
  static const int badResponse = 9998;
  static const int unknownError = 9999;
  static const int unauthorized = 10000;
  static const int violation = 10001;
}

class BaseResponse<T> {
  final T? code;

  /// 数据
  final T? data;

  /// 提示信息
  final String? msg;
  final String? status;
  final T? result;

  /// 错误信息
  final String? error;
  BaseResponse({
    this.code,
    this.data,
    this.msg,
    this.error,
    this.status,
    this.result,
  });
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return BaseResponse<T>(
      code: json['code'],
      msg: json['msg'],
      error: json['error'],
      data: json['data'],
      status: json['status'],
      result: json['result'],
    );
  }
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return <String, dynamic>{
      "code": code,
      "msg": msg,
      "error": error,
      "data": data == null ? null : toJsonT(data as T),
      "status": msg,
      "result": data == null ? null : toJsonT(data as T),
    };
  }
}
