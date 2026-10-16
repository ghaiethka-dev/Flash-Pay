// =============================================================================
//  app_notification.dart — FlashPay
//  Target path: lib/models/app_notification.dart
//  نموذج إشعار محفوظ محلياً (يُسلسَل إلى JSON)
// =============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // chat | transfer_ready | transfer_completed | ...
  final Map<String, String> data;
  final DateTime receivedAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.receivedAt,
    this.read = false,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        data: data,
        receivedAt: receivedAt,
        read: read ?? this.read,
      );

  // ── المظهر حسب النوع ──────────────────────────────────────────────────────
  // محادثة: أزرق (نفس لون "الدعم" في شاشة الدردشة) — حوالة: برتقالي — مكتملة: أخضر
  Color get color {
    switch (type) {
      case 'chat':
        return const Color(0xFF2563EB);
      case 'transfer_completed':
        return const Color(0xFF16A34A);
      case 'transfer_ready':
        return const Color(0xFFC75D05);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  IconData get icon {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'transfer_completed':
        return Icons.verified_rounded;
      case 'transfer_ready':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  /// هل للإشعار وجهة يفتحها عند الضغط؟
  bool get isActionable =>
      type == 'chat' && (int.tryParse(data['transfer_id'] ?? '') ?? 0) > 0;

  // ── التسلسل ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'at': receivedAt.millisecondsSinceEpoch,
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'].toString(),
        title: (j['title'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
        type: (j['type'] ?? '').toString(),
        data: (j['data'] as Map? ?? {})
            .map((k, v) => MapEntry(k.toString(), v.toString())),
        receivedAt: DateTime.fromMillisecondsSinceEpoch(
            (j['at'] as num?)?.toInt() ?? 0),
        read: j['read'] == true,
      );

  static String encodeList(List<AppNotification> list) =>
      jsonEncode(list.map((n) => n.toJson()).toList());

  static List<AppNotification> decodeList(String raw) {
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
