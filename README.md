<div align="center">

<img src="images/logo.png" alt="FlashPay" width="120" />

# ⚡ FlashPay — تطبيق الموبايل

**أرسل حوالتك، تابعها لحظة بلحظة، واستلمها من أقرب مكتب.**

<p>
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%E2%89%A53.3-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State-GetX-A64D04?style=for-the-badge" alt="GetX" />
  <img src="https://img.shields.io/badge/Firebase-FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Platforms" />
</p>

[المزايا](#-المزايا) • [لقطات](#-لقطات-الشاشة) • [التقنيات](#-التقنيات) • [التشغيل](#-التشغيل-السريع) • [البنية](#-بنية-المشروع) • [الفريق](#-الفريق)

</div>

---

<div dir="rtl">

## 📖 نبذة

**FlashPay** منظومة لإدارة الحوالات المالية بين المدن والدول. هذا المستودع هو **تطبيق الموبايل** (Flutter) الموجّه لنوعين من المستخدمين:

| الدور | ماذا يفعل في التطبيق |
|---|---|
| 👤 **الزبون (Customer)** | يُنشئ حوالة محلية أو دولية، يتابع حالتها، ويتحدث مع المكتب عبر محادثة مرتبطة بكل حوالة. |
| 🧑‍💼 **المندوب (Agent)** | يرسل حوالات باسم الزبائن، يدير حوالات البنك، ويراجع صندوقه وأرباحه. |

> موظفو المكاتب (المدير، المحاسب، الصندوق) والإدارة العليا يعملون من **لوحات الويب** وليس من هذا التطبيق.

## 🧩 منظومة FlashPay

| المستودع | الوصف |
|---|---|
| 📱 **Flash-Pay** (هذا المستودع) | تطبيق الموبايل — Flutter |
| 🛠️ [FlashPay-Back](https://github.com/Ameerdawara/FlashPay-Back) | الـ API والخدمات اللحظية — Laravel |
| 🖥️ [FlashPay-Front](https://github.com/Kaisalafef/FlashPay-Front) | لوحات الإدارة على الويب |

```
 تطبيق الموبايل ─┐
                 ├──►  FlashPay-Back (REST API + Reverb/Pusher + FCM)  ◄──┐
 لوحات الويب   ──┘                                                        │
                                                          قاعدة البيانات ─┘
```

## ✨ المزايا

**للزبون**
- 🔐 تسجيل دخول وإنشاء حساب واستعادة كلمة المرور، مع **دخول بالبصمة / الوجه** (`local_auth`).
- 💸 **حوالة محلية ودولية** بعملة إرسال وعملة استلام، واختيار المكتب أو المدينة.
- 🔎 **رقم تتبع** لكل حوالة بصيغة `TRX-…` وحالات واضحة: `قيد الانتظار` ← `جاهزة` ← `مكتملة`.
- 💬 **محادثة لحظية** مع المكتب داخل كل حوالة، تدعم إرسال الصور.
- 🔔 **إشعارات فورية** عند اعتماد الحوالة أو تسليمها (Firebase Cloud Messaging).
- 👤 صفحة حساب وسجل حوالات، وشاشة «كيف يعمل التطبيق».

**للمندوب**
- 📤 إرسال حوالة نيابةً عن زبون.
- 🏦 **حوالات بنكية** مع متابعة الموافقة.
- 📥 تبويبات للحوالات الواردة والمعتمدة، وشاشة **صندوق المندوب** وتفاصيله.

**عام**
- 🌗 وضع فاتح وداكن (أسود فاخر).
- 🌍 واجهة **عربية (RTL)** و**إنجليزية** مع تبديل فوري.
- 🚫 شاشة حظر للحسابات المعطّلة.
- 🎞️ حركات انتقال موحّدة تحترم إعداد «تقليل الحركة» في النظام.

## 🖼️ لقطات الشاشة

> أضف لقطاتك هنا — يفضّل 4–5 صور بنفس الحجم.

| تسجيل الدخول | الرئيسية | إنشاء حوالة | المحادثة | الإعدادات |
|:--:|:--:|:--:|:--:|:--:|
| `docs/screens/login.png` | `docs/screens/home.png` | `docs/screens/send.png` | `docs/screens/chat.png` | `docs/screens/settings.png` |

## 🛠️ التقنيات

| الغرض | الحزمة |
|---|---|
| إدارة الحالة والتوجيه | [`get`](https://pub.dev/packages/get) |
| الشبكة | [`dio`](https://pub.dev/packages/dio) مع حقن تلقائي لـ Bearer token |
| التخزين المحلي | `get_storage` • `shared_preferences` |
| الإشعارات | `firebase_core` • `firebase_messaging` |
| المحادثة اللحظية | `pusher_client_fixed` |
| البصمة | `local_auth` |
| الواجهة والحركة | `lottie` • `flutter_animate` • `shimmer` • `google_nav_bar` |
| أدوات | `image_picker` • `image_gallery_saver_plus` • `url_launcher` • `intl_phone_field` • `flutter_ringtone_player` |

## 🚀 التشغيل السريع

**المتطلبات:** Flutter SDK (Dart `>=3.3.0 <4.0.0`) • Android Studio أو Xcode.

```bash
# 1) استنسخ المشروع
git clone https://github.com/ghaiethka-dev/Flash-Pay.git
cd Flash-Pay

# 2) ثبّت الحزم
flutter pub get

# 3) شغّل على جهاز أو محاكي
flutter run
```

**إعداد الـ API** — عدّل العنوان في `lib/data/network/api_constants.dart`:

```dart
static const String baseUrl = "https://api.flashpay.website/api";
```

**Firebase** — ضع ملف `google-services.json` في `android/app/` (و`GoogleService-Info.plist` لنظام iOS) ثم حدّث `lib/firebase_options.dart` بمشروعك عبر `flutterfire configure`.

**بناء نسخة الإنتاج**

```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Google Play
flutter build ios --release          # iOS

# توليد أيقونة التطبيق من images/ic.png
dart run flutter_launcher_icons
```

## 🗂️ بنية المشروع

```
lib/
├── main.dart                 # نقطة الدخول + المسارات (GetX)
├── core/                     # الثيم، الألوان، الانتقالات، المدقّقات، رسائل الخطأ
├── data/
│   ├── network/              # ApiClient (Dio) + ApiConstants
│   └── local/                # StorageService (التوكن والدور)
├── models/                   # User • Message • AppNotification
├── repos/                    # auth_repo
├── controllers/              # منطق الشاشات (Auth, Chat, Dashboard, Profile, ...)
└── views/
    ├── auth/                 # Splash • Login • Register • ForgotPassword
    ├── dashboards/
    │   ├── user_dashboards/  # الرئيسية • الإشعارات • الحساب
    │   └── agent_dashboards/ # إرسال • بنكي • الصندوق • الواردة
    ├── chat/                 # محادثة الحوالة
    ├── profile/ • settings/  # الحساب والإعدادات
    └── create_remittance.dart • create_intl_remittance.dart
```

**المسارات:** `/splash` ← `/login` ← (`/user_dashboard` للزبون | `/agent_dashboard` للمندوب | `/blocked` للحساب المعطّل)

## 🎨 هوية التصميم

| العنصر | القيمة |
|---|---|
| اللون الأساسي | `#A64D04` (برتقالي محروق) |
| اللون الفاتح للتمييز | `#E8834A` |
| الخلفية الداكنة | `#0A0A0A` • الأسطح `#141414` • البطاقات `#1C1C1C` |
| الخط | Tajawal |
| الاتجاه | RTL افتراضياً |

## 👥 الفريق

| الاسم | الدور |
|---|---|
| قيس العفيف | مهندس برمجيات |
| أمير دوارة | مهندس برمجيات |
| غيث كحل | مهندس برمجيات |
| دلع عدوان | مهندسة برمجيات |

## 📄 الترخيص

مشروع خاص بـ **FlashPay**. جميع الحقوق محفوظة © 2026.

</div>
