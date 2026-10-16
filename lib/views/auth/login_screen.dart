// =============================================================================
//  lib/views/auth/login_screen.dart
//  🎨 هوية الـ Splash: خلفية سوداء + شبكة + توهج ذهبي + شعار وعنوان ذهبيان
//  ✅ منطق AuthController كما هو (login / toggleLoginPassword / المتحكمات)
//  ✅ تحقق inline عند مغادرة الحقل + رسائل عربية واضحة تحت كل حقل
//  ✅ منع الضغط المزدوج أثناء التحميل + اهتزاز وتركيز على أول حقل خاطئ
//  ✅ دخول متدرّج للعناصر (يحترم "تقليل الحركة")
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flashpay/core/app_transitions.dart';
import 'package:flashpay/core/validators.dart';
import 'package:flashpay/views/auth/widgets/fp_auth_field.dart';
import 'package:flashpay/views/auth/widgets/fp_auth_style.dart';

import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController =
  Get.put(AuthController(), permanent: true);

  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState<String>>();
  final _passKey = GlobalKey<FormFieldState<String>>();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _shakeKey = GlobalKey<FPShakeState>();

  @override
  void dispose() {
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (authController.isLoading.value) return;

    if (_formKey.currentState?.validate() ?? false) {
      authController.login();
      return;
    }

    HapticFeedback.lightImpact();
    _shakeKey.currentState?.shake();
    if (_emailKey.currentState?.hasError ?? false) {
      _emailFocus.requestFocus();
    } else if (_passKey.currentState?.hasError ?? false) {
      _passFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FPAuthTheme(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: FPAuth.bg,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: FPAuth.bg,
            body: FPAuthBackground(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── الهوية (مطابقة للـ Splash) ──
                          const FPAuthLogo(size: 88).fpEntrance(context, 0),
                          const SizedBox(height: 4),
                          const FPAuthBrand(fontSize: 36)
                              .fpEntrance(context, 1),
                          const SizedBox(height: 12),
                          const Text(
                            'تحويل فوري  ·  آمن  ·  موثوق',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: FPAuth.textSub,
                              letterSpacing: 1.0,
                            ),
                          ).fpEntrance(context, 2),
                          const SizedBox(height: 28),

                          // ── النموذج ──
                          FPShake(
                            key: _shakeKey,
                            child: FPAuthCard(
                              child: AutofillGroup(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'تسجيل الدخول',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: FPAuth.text,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'نظام إدارة الحوالات المالية',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 13,
                                          color: FPAuth.textSub,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      FPAuthField(
                                        label: 'البريد الإلكتروني',
                                        hint: 'example@flashpay.com',
                                        icon: Icons.email_outlined,
                                        controller:
                                        authController.loginEmailController,
                                        fieldKey: _emailKey,
                                        focusNode: _emailFocus,
                                        keyboardType:
                                        TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email
                                        ],
                                        inputFormatters: [
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'\s')),
                                        ],
                                        validator: FPValidators.email,
                                        onSubmitted: (_) =>
                                            _passFocus.requestFocus(),
                                      ),
                                      const SizedBox(height: 16),

                                      Obx(() => FPAuthField(
                                        label: 'كلمة المرور',
                                        hint: 'أدخل كلمة المرور',
                                        icon: Icons.lock_outline,
                                        controller: authController
                                            .loginPasswordController,
                                        fieldKey: _passKey,
                                        focusNode: _passFocus,
                                        isPassword: true,
                                        isObscured: authController
                                            .isLoginPasswordHidden.value,
                                        onTogglePassword: authController
                                            .toggleLoginPassword,
                                        textInputAction:
                                        TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
                                        validator:
                                        FPValidators.loginPassword,
                                        onSubmitted: (_) => _submit(),
                                      )),

                                      Align(
                                        alignment:
                                        AlignmentDirectional.centerStart,
                                        child: FPGoldLink(
                                          label: 'نسيت كلمة المرور؟',
                                          onPressed: () =>
                                              Get.toNamed('/forgot_password'),
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // ── زر تسجيل الدخول ──
                                      Obx(() => FPGoldButton(
                                        label: 'تسجيل الدخول',
                                        loading:
                                        authController.isLoading.value,
                                        onPressed: _submit,
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ).fpEntrance(context, 3),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ليس لديك حساب؟',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: FPAuth.textSub,
                                ),
                              ),
                              FPGoldLink(
                                label: 'إنشاء حساب',
                                bold: true,
                                onPressed: () => Get.toNamed('/register'),
                              ),
                            ],
                          ).fpEntrance(context, 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}