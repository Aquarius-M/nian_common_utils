import 'dart:convert';

import 'package:nian_common_utils/utils/log_utils/app_log_utils.dart';

class ReceivedInfo {
  ReceivedInfo({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int? id;
  final String? title;
  final String? body;
  final NoticePayload? payload;
}

class NoticePayload {
  String? path;
  Map<String, dynamic>? data;

  NoticePayload({this.path, this.data});

  factory NoticePayload.fromJson(String? json) {
    Map<String, dynamic>? map;
    NoticePayload payload = NoticePayload();
    try {
      map = jsonDecode(json ?? '');
      payload.path = map?['path'];
      payload.data = map?['data'];
    } catch (e) {
      AppLog.w(e);
    }
    return payload;
  }

  String toJsonString() {
    var json = <String, dynamic>{
      'path': path,
      if (data != null && data?.isNotEmpty == true) 'data': data,
    };
    return jsonEncode(json);
  }
}
