class ApiConstants {
  // 🔴 استبدل 192.168.1.15 بالرقم الخاص بحاسوبك الذي ظهر في الـ CMD
  // وتأكد من كتابة http وليس https (لأنك تعمل محلياً)
  static const String baseUrl = "http://192.168.8.9:8000/api";
  
  static const String loginEndpoint = "/login";
  static const String registerEndpoint = "/register";
  static const String logoutEndpoint = "/logout";
  static const String meEndpoint = '/me';
}