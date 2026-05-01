# ── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── slf4j (R8 missing class fix) ─────────────────────────────────────────────
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }
-keep class org.slf4j.impl.** { *; }

# ── OkHttp / Retrofit / Dio (إذا كنت تستخدمها عبر مكتبات) ───────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# ── Pusher ────────────────────────────────────────────────────────────────────
-dontwarn com.pusher.**
-keep class com.pusher.** { *; }

# ── Firebase ──────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ── تجاهل أي missing classes أخرى من R8 ─────────────────────────────────────
-ignorewarnings
