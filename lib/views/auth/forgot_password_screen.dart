// =============================================================================
//  lib/views/auth/forgot_password_screen.dart
//  ✅ منطق AuthController كما هو (resetStep / sendResetCode / submitNewPassword ...)
//  ✅ تحقق inline: البريد، رمز من 6 أرقام، كلمة مرور 8+، تطابق التأكيد
//  ✅ انتقال سلس بين الخطوتين (AnimatedSize + دخول متدرّج) وتركيز تلقائي على الرمز
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flashpay/core/app_transitions.dart';
import 'package:flashpay/core/validators.dart';
import 'package:flashpay/views/auth/widgets/fp_auth_field.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState<String>>();
  final _codeKey = GlobalKey<FormFieldState<String>>();
  final _passKey = GlobalKey<FormFieldState<String>>();
  final _confirmKey = GlobalKey<FormFieldState<String>>();

  final _emailFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _shakeKey = GlobalKey<FPShakeState>();

  Worker? _stepWorker;

  @override
  void initState() {
    super.initState();
    // عند الانتقال إلى خطوة الرمز: ركّز على حقل الرمز مباشرة
    _stepWorker = ever(authController.resetStep, (dynamic step) {
      if (step == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _codeFocus.requestFocus();
        });
      }
    });
  }

  @override
  void dispose() {
    _stepWorker?.dispose();
    _emailFocus.dispose();
    _codeFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (authController.isLoading.value) return;

    if (_formKey.currentState?.validate() ?? false) {
      if (authController.resetStep.value == 0) {
        authController.sendResetCode();
      } else {
        authController.submitNewPassword();
      }
      return;
    }

    HapticFeedback.lightImpact();
    _shakeKey.currentState?.shake();
    if (_emailKey.currentState?.hasError ?? false) {
      _emailFocus.requestFocus();
    } else if (_codeKey.currentState?.hasError ?? false) {
      _codeFocus.requestFocus();
    } else if (_passKey.currentState?.hasError ?? false) {
      _passFocus.requestFocus();
    } else if (_confirmKey.currentState?.hasError ?? false) {
      _confirmFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = AppColors.primaryGradient.colors.first;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('استعادة كلمة المرور'),
        ),
        body: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24.0),
            child: FPShake(
              key: _shakeKey,
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: isDark
                      ? []
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Obx(() {
                    final int step = authController.resetStep.value;
                    final bool loading = authController.isLoading.value;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_reset_rounded,
                          size: 64,
                          color: primary,
                        ).fpEntrance(context, 0),
                        const SizedBox(height: 16),

                        AnimatedSwitcher(
                          duration: FPMotion.medium,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: Text(
                            step == 0
                                ? 'أدخل بريدك الإلكتروني لإرسال رمز التحقق'
                                : 'أدخل رمز التحقق وكلمة المرور الجديدة',
                            key: ValueKey<int>(step),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                              isDark ? Colors.white70 : Colors.grey.shade600,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── خطوة 1: البريد الإلكتروني ──
                        FPAuthField(
                          label: 'البريد الإلكتروني',
                          hint: 'example@flashpay.com',
                          icon: Icons.email_outlined,
                          controller: authController.resetEmailController,
                          fieldKey: _emailKey,
                          focusNode: _emailFocus,
                          enabled: step == 0,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.email],
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          validator: FPValidators.email,
                          onSubmitted: (_) => _submit(),
                        ),

                        // ── خطوة 2: الرمز + كلمة المرور الجديدة ──
                        AnimatedSize(
                          duration: FPMotion.medium,
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: step == 1
                              ? Column(
                            children: [
                              const SizedBox(height: 16),
                              FPAuthField(
                                label: 'رمز التحقق',
                                hint: '------',
                                icon: Icons.pin_outlined,
                                controller:
                                authController.resetCodeController,
                                fieldKey: _codeKey,
                                focusNode: _codeFocus,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                maxLength: 6,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: FPValidators.otpCode,
                                onSubmitted: (_) =>
                                    _passFocus.requestFocus(),
                              ).fpEntrance(context, 0),
                              const SizedBox(height: 16),
                              FPAuthField(
                                label: 'كلمة المرور الجديدة',
                                hint: 'كلمة مرور من 8 أحرف على الأقل',
                                icon: Icons.lock_outline,
                                controller:
                                authController.resetPassController,
                                fieldKey: _passKey,
                                focusNode: _passFocus,
                                isPassword: true,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword
                                ],
                                validator: FPValidators.newPassword,
                                onChanged: (_) {
                                  // أعد فحص التأكيد إذا كُتب مسبقًا
                                  if (authController
                                      .resetConfirmPassController
                                      .text
                                      .isNotEmpty) {
                                    _confirmKey.currentState?.validate();
                                  }
                                },
                                onSubmitted: (_) =>
                                    _confirmFocus.requestFocus(),
                              ).fpEntrance(context, 1),
                              const SizedBox(height: 16),
                              FPAuthField(
                                label: 'تأكيد كلمة المرور',
                                hint: 'أعد كتابة كلمة المرور',
                                icon: Icons.lock_outline,
                                controller: authController
                                    .resetConfirmPassController,
                                fieldKey: _confirmKey,
                                focusNode: _confirmFocus,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.newPassword
                                ],
                                validator: FPValidators.confirmPassword(
                                    authController.resetPassController),
                                onSubmitted: (_) => _submit(),
                              ).fpEntrance(context, 2),
                            ],
                          )
                              : const SizedBox(width: double.infinity),
                        ),

                        const SizedBox(height: 32),

                        // ── الزر الرئيسي ──
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14.0),
                            boxShadow: [
                              BoxShadow(
                                color:
                                const Color(0xFFA64D04).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0)),
                            ),
                            child: AnimatedSwitcher(
                              duration: FPMotion.fast,
                              child: loading
                                  ? const SizedBox(
                                key: ValueKey('loading'),
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Text(
                                step == 0
                                    ? 'إرسال رمز التحقق'
                                    : 'تغيير كلمة المرور',
                                key: ValueKey<int>(step),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (step == 1) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed:
                            loading ? null : authController.sendResetCode,
                            child: Text(
                              'إعادة إرسال الرمز',
                              style: TextStyle(color: primary),
                            ),
                          ).fpEntrance(context, 3),
                        ],
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}