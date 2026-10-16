class MessageModel {
  final int     id;
  final int     senderId;
  final String  text;
  final String  senderName;
  // الدور — يأتي من sender.role في الـ JSON
  final String  senderRole;
  final String  createdAt;
  final String? imageUrl;
  // ✅ هل قُرئت الرسالة؟ (يُستخدم لعلامتَي ✓✓ ويتحدّث تلقائياً مع التحديث الدوري)
  final bool    isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.senderName,
    this.senderRole = 'customer',
    required this.createdAt,
    this.imageUrl,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    final dynamic read = json['is_read'];

    return MessageModel(
      id:         json['id'] as int,
      senderId:   json['sender_id'] as int,
      text:       json['message'] ?? '',
      senderName: sender?['name'] ?? 'غير معروف',
      senderRole: sender?['role'] ?? 'customer',
      createdAt:  json['created_at'] ?? '',
      imageUrl:   (json['image'] != null && json['image'].toString().isNotEmpty)
          ? json['image'].toString()
          : null,
      isRead: read == true || read == 1 || read == '1',
    );
  }

  /// true إذا كان المرسل موظفاً (مدير، كاشير، محاسب...)
  bool get isStaff => senderRole != 'customer';
}