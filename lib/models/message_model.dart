class MessageModel {
  final int id;
  final int senderId;
  final String text;
  final String senderName;
  final String createdAt;
  final String? imageUrl;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.senderName,
    required this.createdAt,
    this.imageUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      text: json['message']??'',
      // الـ API الخاص بنا يرجع اسم المرسل بداخل كائن sender
      senderName: json['sender'] != null ? json['sender']['name'] : 'غير معروف',
      createdAt: json['created_at'] ?? '',
      imageUrl: json['image'] ?? '',
    );
  }
}