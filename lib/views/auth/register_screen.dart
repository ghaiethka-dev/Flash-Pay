// =============================================================================
//  lib/views/auth/register_screen.dart
//  🎨 هوية الـ Splash: خلفية سوداء + شبكة + توهج ذهبي + شعار وعنوان ذهبيان
//  ✅ منطق AuthController كما هو (register / countries / cities / idCardImages ...)
//  ✅ تحقق inline لكل الحقول + الدولة/المدينة + صور الهوية الثلاث (مع تحديد الناقص)
//  ✅ عند الفشل: اهتزاز + تمرير تلقائي وتركيز على أول حقل خاطئ
//  ✅ منع الإرسال المزدوج أثناء التحميل + دخول متدرّج للرأس
//  ℹ️ استُبدل Lottie (CryptoWallet) بشعار FlashPay الذهبي ليتطابق مع الـ Splash
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:flashpay/core/app_transitions.dart';
import 'package:flashpay/core/validators.dart';
import 'package:flashpay/views/auth/widgets/fp_auth_field.dart';
import 'package:flashpay/views/auth/widgets/fp_auth_style.dart';

import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _FieldRef {
  final GlobalKey<FormFieldState<dynamic>> key;
  final FocusNode? focus;
  const _FieldRef(this.key, [this.focus]);
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final _shakeKey = GlobalKey<FPShakeState>();

  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _emailKey = GlobalKey<FormFieldState<String>>();
  final _passKey = GlobalKey<FormFieldState<String>>();
  final _confirmKey = GlobalKey<FormFieldState<String>>();
  final _countryKey = GlobalKey<FormFieldState<int>>();
  final _cityKey = GlobalKey<FormFieldState<int>>();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  final _phoneAnchor = GlobalKey();
  final _idAnchor = GlobalKey();

  bool _showIdError = false;

  late final List<_FieldRef> _orderedFields = [
    _FieldRef(_nameKey, _nameFocus),
    _FieldRef(_emailKey, _emailFocus),
    _FieldRef(_countryKey),
    _FieldRef(_cityKey),
    _FieldRef(_passKey, _passFocus),
    _FieldRef(_confirmKey, _confirmFocus),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.countries.isEmpty) {
        authController.fetchCountriesAndCities();
      }
    });
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  int get _uploadedCount =>
      authController.idCardImages.where((img) => img != null).length;

  // ── إرسال النموذج ──────────────────────────────────────────────────────
  void _submit() {
    FocusScope.of(context).unfocus();
    if (authController.isLoading.value) return;

    final bool formOk = _formKey.currentState?.validate() ?? false;
    final bool idOk = _uploadedCount == 3;

    if (formOk && idOk) {
      authController.register();
      return;
    }

    setState(() => _showIdError = !idOk);
    HapticFeedback.lightImpact();
    _shakeKey.currentState?.shake();

    // بعد إعادة البناء (ظهور رسائل الخطأ) مرّر إلى أول حقل خاطئ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final f in _orderedFields) {
        if (f.key.currentState?.hasError ?? false) {
          _scrollTo(f.key.currentContext);
          f.focus?.requestFocus();
          return;
        }
      }
      if (!formOk) {
        // لا حقل نصي خاطئ → الخطأ في رقم الهاتف
        _scrollTo(_phoneAnchor.currentContext);
        _phoneFocus.requestFocus();
        return;
      }
      _scrollTo(_idAnchor.currentContext);
    });
  }

  void _scrollTo(BuildContext? ctx) {
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.2,
      duration: FPMotion.medium,
      curve: Curves.easeOutCubic,
    );
  }

  // ── الواجهة ─────────────────────────────────────────────────────────────
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
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                tooltip: 'رجوع',
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: FPAuth.goldLight, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            body: FPAuthBackground(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── الهوية (مطابقة للـ Splash) ──
                          const FPAuthLogo(size: 70).fpEntrance(context, 0),
                          const FPAuthBrand(fontSize: 30)
                              .fpEntrance(context, 1),
                          const SizedBox(height: 12),
                          const Text(
                            'أنشئ حسابك للبدء في تحويل الأموال',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: FPAuth.textSub,
                            ),
                          ).fpEntrance(context, 2),
                          const SizedBox(height: 24),

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
                                        'حساب جديد',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: FPAuth.text,
                                        ),
                                      ),
                                      const SizedBox(height: 22),

                                      FPAuthField(
                                        label: 'الاسم الكامل',
                                        hint: 'أدخل اسمك الثلاثي',
                                        icon: Icons.person_outline,
                                        controller:
                                        authController.fullNameController,
                                        fieldKey: _nameKey,
                                        focusNode: _nameFocus,
                                        keyboardType: TextInputType.name,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.name
                                        ],
                                        validator: FPValidators.fullName,
                                        onSubmitted: (_) =>
                                            _emailFocus.requestFocus(),
                                      ),
                                      const SizedBox(height: 16),

                                      FPAuthField(
                                        label: 'البريد الإلكتروني',
                                        hint: 'مثال: email@domain.com',
                                        icon: Icons.email_outlined,
                                        controller: authController
                                            .registerEmailController,
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
                                            _phoneFocus.requestFocus(),
                                      ),
                                      const SizedBox(height: 16),

                                      _buildPhoneField(context),
                                      const SizedBox(height: 16),

                                      // ── الدولة والمدينة ──
                                      _buildCountryCityRow(context),
                                      const SizedBox(height: 16),

                                      Obx(() => FPAuthField(
                                        label: 'كلمة المرور',
                                        hint:
                                        'أدخل كلمة مرور قوية (8 أحرف على الأقل)',
                                        icon: Icons.lock_outline,
                                        controller: authController
                                            .registerPasswordController,
                                        fieldKey: _passKey,
                                        focusNode: _passFocus,
                                        isPassword: true,
                                        isObscured: authController
                                            .isRegisterPasswordHidden.value,
                                        onTogglePassword: authController
                                            .toggleRegisterPassword,
                                        textInputAction:
                                        TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.newPassword
                                        ],
                                        validator: FPValidators.newPassword,
                                        onChanged: (_) {
                                          if (authController
                                              .confirmRegisterPasswordController
                                              .text
                                              .isNotEmpty) {
                                            _confirmKey.currentState
                                                ?.validate();
                                          }
                                        },
                                        onSubmitted: (_) =>
                                            _confirmFocus.requestFocus(),
                                      )),
                                      const SizedBox(height: 16),

                                      Obx(() => FPAuthField(
                                        label: 'تأكيد كلمة المرور',
                                        hint: 'أعد إدخال كلمة المرور',
                                        icon: Icons.lock_reset,
                                        controller: authController
                                            .confirmRegisterPasswordController,
                                        fieldKey: _confirmKey,
                                        focusNode: _confirmFocus,
                                        isPassword: true,
                                        isObscured: authController
                                            .isConfirmRegisterPasswordHidden
                                            .value,
                                        onTogglePassword: authController
                                            .toggleConfirmRegisterPassword,
                                        textInputAction:
                                        TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.newPassword
                                        ],
                                        validator:
                                        FPValidators.confirmPassword(
                                            authController
                                                .registerPasswordController),
                                      )),
                                      const SizedBox(height: 28),

                                      _buildIdImagesSection(context),
                                      const SizedBox(height: 24),

                                      // ── زر إنشاء الحساب ──
                                      Obx(() => FPGoldButton(
                                        label: 'إنشاء حساب',
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

                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'لديك حساب بالفعل ؟',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: FPAuth.textSub,
                                ),
                              ),
                              FPGoldLink(
                                label: 'تسجيل الدخول',
                                bold: true,
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
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

  // ── الدولة والمدينة ─────────────────────────────────────────────────────
  Widget _buildCountryCityRow(BuildContext context) {
    const TextStyle itemStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      color: FPAuth.text,
    );

    return Obx(() {
      if (authController.isLoadingCountries.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: CircularProgressIndicator(color: FPAuth.gold),
          ),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(() => FPAuthDropdown<int>(
              label: 'البلد',
              hint: 'اختر البلد',
              icon: Icons.public,
              fieldKey: _countryKey,
              value: authController.selectedCountryId.value,
              validator: FPValidators.selected<int>('اختر البلد'),
              items: authController.countries
                  .map((c) => DropdownMenuItem<int>(
                value: c['id'] as int,
                child: Text(c['name'] as String, style: itemStyle),
              ))
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                final country = authController.countries
                    .firstWhere((c) => c['id'] == val);
                authController.changeCountry(val, country['name'] as String);
                // المدينة السابقة لم تعد صالحة
                _cityKey.currentState?.reset();
              },
            )),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(() => FPAuthDropdown<int>(
              label: 'المدينة',
              hint: 'اختر المدينة',
              icon: Icons.location_city,
              fieldKey: _cityKey,
              value: authController.selectedCityId.value,
              validator: (v) {
                if (v != null) return null;
                return authController.selectedCountryId.value == null
                    ? 'اختر البلد أولًا ثم المدينة'
                    : 'اختر المدينة';
              },
              items: authController.availableCities
                  .map((c) => DropdownMenuItem<int>(
                value: c['id'] as int,
                child: Text(c['name'] as String, style: itemStyle),
              ))
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                final city = authController.availableCities
                    .firstWhere((c) => c['id'] == val);
                authController.changeCity(val, city['name'] as String);
              },
            )),
          ),
        ],
      );
    });
  }

  // ✅ حقل الهاتف الدولي (التحقق من الطول حسب الدولة داخل المكتبة نفسها)
  Widget _buildPhoneField(BuildContext context) {
    final Color err = fpErrorColor(true);

    OutlineInputBorder border(Color c, [double w = 1.0]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: c, width: w));

    return Column(
      key: _phoneAnchor,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ExcludeSemantics(
          child: Text(
            'رقم الهاتف',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: FPAuth.text),
          ),
        ),
        const SizedBox(height: 8),
        Directionality(
          // IntlPhoneField يعمل بـ LTR دائماً لأن الأرقام LTR
          textDirection: TextDirection.ltr,
          child: IntlPhoneField(
            controller: authController.registerPhoneController,
            focusNode: _phoneFocus,
            initialCountryCode: 'SY',
            keyboardType: TextInputType.phone,
            invalidNumberMessage:
            'رقم الهاتف غير صالح لهذه الدولة، تحقق من عدد الأرقام',
            style: const TextStyle(color: FPAuth.text),
            cursorColor: FPAuth.gold,
            dropdownTextStyle: const TextStyle(color: FPAuth.text),
            dropdownIcon:
            const Icon(Icons.arrow_drop_down, color: FPAuth.gold),
            decoration: InputDecoration(
              hintText: '912 345 678',
              hintStyle: const TextStyle(color: FPAuth.hint, fontSize: 13),
              filled: true,
              fillColor: FPAuth.fieldFill,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorMaxLines: 3,
              errorStyle: TextStyle(
                  color: err,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600),
              border: border(FPAuth.border),
              enabledBorder: border(FPAuth.border),
              focusedBorder: border(FPAuth.gold, 1.5),
              errorBorder: border(err, 1.5),
              focusedErrorBorder: border(err, 2.0),
            ),
            // ✅ نحفظ الرقم الكامل (كود الدولة + الرقم) في الكنترولر
            onChanged: (phone) {
              authController.setRegisterPhone(phone.completeNumber);
            },
            onCountryChanged: (country) {
              // إعادة حساب الرقم الكامل عند تغيير الدولة
              final current = authController.registerPhoneController.text;
              if (current.isNotEmpty) {
                authController.setRegisterPhone('+${country.dialCode}$current');
              }
            },
          ),
        ),
      ],
    );
  }

  // ✅ قسم صور الهوية الثلاث
  Widget _buildIdImagesSection(BuildContext context) {
    final Color err = fpErrorColor(true);

    return Obx(() {
      final images = authController.idCardImages;
      final int uploaded = images.where((img) => img != null).length;
      final bool showError = _showIdError && uploaded < 3;
      final missing = <String>[
        for (int i = 0; i < 3; i++)
          if (images[i] == null) authController.imageLabel(i),
      ];

      return Container(
        key: _idAnchor,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FPAuth.gold.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: FPAuth.gold.withOpacity(0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: FPAuth.gold.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.badge_outlined,
                      size: 19, color: FPAuth.gold),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'صور الهوية',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: FPAuth.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'يرجى رفع الصور الثلاث للتحقق من هويتك',
              style: TextStyle(fontSize: 12.5, color: FPAuth.textSub),
            ),
            const SizedBox(height: 16),

            _buildSingleImagePicker(
              context: context,
              index: 0,
              image: images[0],
              heightIfEmpty: 120,
              hasError: showError && images[0] == null,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildSingleImagePicker(
                    context: context,
                    index: 1,
                    image: images[1],
                    heightIfEmpty: 110,
                    hasError: showError && images[1] == null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSingleImagePicker(
                    context: context,
                    index: 2,
                    image: images[2],
                    heightIfEmpty: 110,
                    hasError: showError && images[2] == null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildImagesProgressIndicator(),

            // رسالة الخطأ: تذكر الصور الناقصة بالاسم
            AnimatedSize(
              duration: FPMotion.medium,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: showError
                  ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 16, color: err),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ارفع الصور الناقصة: ${missing.join('، ')}',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: err),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSingleImagePicker({
    required BuildContext context,
    required int index,
    required dynamic image, // File?
    required double heightIfEmpty,
    required bool hasError,
  }) {
    final Color err = fpErrorColor(true);
    final label = authController.imageLabel(index);
    final icon = authController.imageIcon(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: FPAuth.textSub),
        ),
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: image != null ? 'تغيير $label' : 'رفع $label',
          child: GestureDetector(
            onTap: () => authController.pickIdCardImage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: image != null ? (index == 0 ? 160 : 120) : heightIfEmpty,
              decoration: BoxDecoration(
                color: image != null ? Colors.transparent : FPAuth.fieldFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: image != null
                      ? FPAuth.gold
                      : (hasError ? err : FPAuth.border),
                  width: image != null ? 2 : (hasError ? 2 : 1.5),
                ),
              ),
              child: image != null
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(image, fit: BoxFit.cover),
                  ),
                  // زر الحذف (هدف لمس ≥ 36px)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Semantics(
                      button: true,
                      label: 'حذف $label',
                      child: InkResponse(
                        onTap: () =>
                            authController.removeIdCardImage(index),
                        radius: 22,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ),
                  // زر التغيير
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit,
                              color: FPAuth.goldLight, size: 12),
                          SizedBox(width: 4),
                          Text('تغيير',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: index == 0 ? 36 : 28,
                      color: hasError ? err : FPAuth.gold),
                  const SizedBox(height: 6),
                  Text(
                    'اضغط لرفع الصورة',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasError ? err : FPAuth.goldLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // مؤشر الاكتمال (كم صورة تم رفعها)
  Widget _buildImagesProgressIndicator() {
    final uploaded = _uploadedCount;
    final bool complete = uploaded == 3;
    final Color color = complete ? FPAuth.success : FPAuth.gold;

    return Row(
      children: [
        ...List.generate(3, (i) {
          final done = authController.idCardImages[i] != null;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(left: i < 2 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: done ? color : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        Text(
          '$uploaded / 3',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: complete ? FPAuth.success : FPAuth.textSub),
        ),
      ],
    );
  }
}