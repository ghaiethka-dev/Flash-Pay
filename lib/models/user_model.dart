class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? country;
  final String? city;
  final String? role; // 'user' أو 'agent'
  final String? token; // حفظ التوكن القادم من الاستجابة

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.country,
    this.city,
    this.role,
    this.token,
  });

  // دالة لتحويل استجابة الـ JSON (القادمة من Laravel) إلى كائن Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      country: json['country'],
      city: json['city'],
      role: json['role'],
      // أحياناً يرسل Laravel التوكن خارج كائن المستخدم، وأحياناً بداخله
      // هذا يعتمد على طريقة برمجتك للـ API لاحقاً
      token: json['token'], 
    );
  }

  // دالة لتحويل كائن Dart إلى JSON (مفيدة إذا أردت حفظ بيانات المستخدم محلياً)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'city': city,
      'role': role,
      'token': token,
    };
  }
}