import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';

class RewardAlerts {
  RewardAlerts();

  static const _seenKey = 'hll_seen_news';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final Set<String> _seen = {};
  var _ready = false;
  var openedRewards = false;
  Future<void> _queue = Future<void>.value();
  void Function()? onOpen;
  Uint8List? _poster;

  Future<void> prepare() async {
    final prefs = await SharedPreferences.getInstance();
    _seen.addAll(prefs.getStringList(_seenKey) ?? const []);
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) {
        openedRewards = true;
        onOpen?.call();
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final launch = await _plugin.getNotificationAppLaunchDetails();
    openedRewards = (launch?.didNotificationLaunchApp ?? false) &&
        launch?.notificationResponse?.payload == '/news';
    _ready = true;
  }

  Future<void> announce(List<Promotion> items) {
    _queue = _queue.then((_) => _announce(items));
    return _queue;
  }

  Future<void> _announce(List<Promotion> items) async {
    if (!_ready) {
      return;
    }
    final fresh = items.where((item) => !_seen.contains(item.id)).toList();
    if (fresh.isEmpty) {
      return;
    }
    for (final item in fresh) {
      try {
        await _show(item);
      } catch (_) {}
      _seen.add(item.id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenKey, _seen.toList());
  }

  Future<void> _show(Promotion item) async {
    final poster = await _bytes(item);
    final lines = item.body.split('\n');
    final text = lines.length > 1
        ? '${lines.first} ${item.title} ${lines.sublist(1).join(' ')}'
        : '${item.title} ${item.body}'.trim();
    final android = AndroidNotificationDetails(
      'rewards_news',
      'Rewards',
      channelDescription: 'Rewards သတင်းအသစ်',
      importance: Importance.max,
      priority: Priority.high,
      ticker: item.title,
      styleInformation: poster == null
          ? BigTextStyleInformation(text)
          : BigPictureStyleInformation(
              ByteArrayAndroidBitmap(poster),
              contentTitle: item.title,
              summaryText: text,
              hideExpandedLargeIcon: true,
            ),
    );
    await _plugin.show(
      id: item.id.hashCode & 0x7fffffff,
      title: 'HAPPY LA LA LAND',
      body: item.title,
      notificationDetails: NotificationDetails(android: android),
      payload: '/news',
    );
  }

  Future<void> clear() => _plugin.cancelAll();

  Future<Uint8List?> _bytes(Promotion item) async {
    final asset = item.imageAsset;
    if (asset != null) {
      final cached = _poster;
      if (cached != null) {
        return cached;
      }
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      _poster = bytes;
      return bytes;
    }
    final url = item.imageUrl;
    if (url == null || !url.startsWith('https://')) {
      return null;
    }
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 8));
      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        return null;
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
        if (builder.length > 1000000) {
          return null;
        }
      }
      return builder.takeBytes();
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }
}
