import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/user_plan.dart';

/// On-device JSON for the companion’s memory.
abstract final class LocalDisk {
  static const _storeKey = 'bunly.store.v1';
  static const _planKey = 'bunly.plan.v1';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences?> open() async {
    if (_prefs != null) return _prefs;
    try {
      _prefs = await SharedPreferences.getInstance();
      return _prefs;
    } on PlatformException catch (error) {
      debugPrint('LocalDisk open failed: $error');
      _prefs = null;
      return null;
    } catch (error) {
      debugPrint('LocalDisk open failed: $error');
      _prefs = null;
      return null;
    }
  }

  static Future<Map<String, dynamic>?> readStore() async {
    final prefs = await open();
    if (prefs == null) return null;
    final raw = prefs.getString(_storeKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  static Future<void> writeStore(Map<String, dynamic> json) async {
    final prefs = await open();
    if (prefs == null) return;
    await prefs.setString(_storeKey, jsonEncode(json));
  }

  static Future<void> readPlan() async {
    final prefs = await open();
    if (prefs == null) return;
    final raw = prefs.getString(_planKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        UserPlan.instance.readJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
  }

  static Future<void> writePlan() async {
    final prefs = await open();
    if (prefs == null) return;
    await prefs.setString(_planKey, jsonEncode(UserPlan.instance.toJson()));
  }

  static Future<void> eraseAll() async {
    final prefs = await open();
    await prefs?.clear();
  }
}
