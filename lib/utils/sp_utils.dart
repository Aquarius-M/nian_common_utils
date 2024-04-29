import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class SpUtils {
  static SpUtils? _singleton;
  static SharedPreferences? prefs;
  static Lock lock = Lock();

  static Future<SpUtils?> getInstance() async {
    if (_singleton == null) {
      await lock.synchronized(() async {
        if (_singleton == null) {
          // keep local instance till it is fully initialized.
          // 保持本地实例直到完全初始化。
          var singleton = SpUtils._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton;
  }

  SpUtils._();

  Future _init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// get string.
  static String? getString(String key, {String? defValue = ''}) {
    return prefs?.getString(key) ?? defValue;
  }

  /// put string.
  static Future<bool>? setString(String key, String value) {
    return prefs?.setString(key, value);
  }

  /// get bool.
  static bool? getBool(String key, {bool? defValue = false}) {
    return prefs?.getBool(key) ?? defValue;
  }

  /// put bool.
  static Future<bool>? setBool(String key, bool value) {
    return prefs?.setBool(key, value);
  }

  /// get int.
  static int? getInt(String key, {int? defValue = 0}) {
    return prefs?.getInt(key) ?? defValue;
  }

  /// put int.
  static Future<bool>? setInt(String key, int value) {
    return prefs?.setInt(key, value);
  }

  /// get double.
  static double? getDouble(String key, {double? defValue = 0.0}) {
    return prefs?.getDouble(key) ?? defValue;
  }

  /// put double.
  static Future<bool>? setDouble(String key, double value) {
    return prefs?.setDouble(key, value);
  }

  static Future<bool>? setMap(String key, Object value) {
    return prefs?.setString(key, json.encode(value));
  }

  static Map<String, dynamic>? getMap(String key) {
    String? data = prefs?.getString(key);
    return (data == null || data.isEmpty) ? null : json.decode(data);
  }

  static Future<bool>? setList(String key, List value) {
    return prefs?.setString(key, json.encode(value));
  }

  static List? getList(String key) {
    String? data = prefs?.getString(key);
    return (data == null || data.isEmpty) ? null : json.decode(data);
  }

  ///Sp is initialized.
  static bool isInitialized() {
    return prefs != null;
  }

  /// have key.
  static bool? haveKey(String key) {
    return prefs?.getKeys().contains(key);
  }

  /// contains Key.
  static bool? containsKey(String key) {
    return prefs?.containsKey(key);
  }

  /// get keys.
  static Set<String>? getKeys() {
    return prefs?.getKeys();
  }

  /// remove.
  static Future<bool>? remove(String key) {
    return prefs?.remove(key);
  }

  /// clear.
  static Future<bool>? clear() {
    return prefs?.clear();
  }
}
