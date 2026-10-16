// =============================================================================
//  lib/views/create_intl_remittance.dart
//  ✅ منطق CreateIntlRemittanceController كما هو
//  ✅ تحقق inline لكل حقل مطلوب + رسائل واضحة (المكتب اختياري كما هو)
//  ✅ تمرير تلقائي وتركيز على أول حقل خاطئ، وزر إرسال يتعطل أثناء التحميل
//  ✅ تصفير حالة التحقق بعد الإرسال الناجح
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:flashpay/core/app_transitions.dart';
import 'package:flashpay/core/validators.dart';
import 'package:flashpay/views/auth/widgets/fp_auth_field.dart';

import '../controllers/create_intl_remittance_controller.dart';

class CreateIntlRemittanceView extends StatefulWidget {
  const CreateIntlRemittanceView({Key? key}) : super(key: key);

  @override
  State<CreateIntlRemittanceView> createState() =>
      _CreateIntlRemittanceViewState();
}

class _CreateIntlRemittanceViewState extends State<CreateIntlRemittanceView> {
  static const Color _blue = Color(0xFF2980B9);

  final CreateIntlRemittanceController controller =
  Get.put(CreateIntlRemittanceController());

  final _formKey = GlobalKey<FormState>();
  final _amountKey = GlobalKey<FormFieldState<String>>();
  final _sendCurrencyKey = GlobalKey<FormFieldState<int>>();
  final _receiveCurrencyKey = GlobalKey<FormFieldState<int>>();
  final _countryKey = GlobalKey<FormFieldState<int>>();
  final _cityKey = GlobalKey<FormFieldState<String>>();
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _phoneAnchor = GlobalKey();

  final _amountFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  late final List<GlobalKey<FormFieldState<dynamic>>> _order = [
    _amountKey,
    _sendCurrencyKey,
    _receiveCurrencyKey,
    _countryKey,
    _cityKey,
    _nameKey,
  ];

  Worker? _resetWorker;

  @override
  void initState() {
    super.initState();
    // بعد إرسال ناجح: صفّر حالة التحقق (الكنترولر يفرّغ الحقول)
    _resetWorker = ever(controller.resetTick, (dynamic _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formKey.currentState?.reset();
      });
    });
  }

  @override
  void dispose() {
    _resetWorker?.dispose();
    _amountFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (controller.isLoading.value) return;

    if (_formKey.currentState?.validate() ?? false) {
      controller.submitTransfer();
      return;
    }

    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final k in _order) {
        if (k.currentState?.hasError ?? false) {
          _scrollTo(k.currentContext);
          if (k == _amountKey) _amountFocus.requestFocus();
          if (k == _nameKey) _nameFocus.requestFocus();
          return;
        }
      }
      // لا حقل آخر خاطئ → الخطأ في رقم الهاتف
      _scrollTo(_phoneAnchor.currentContext);
      _phoneFocus.requestFocus();
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'إرسال حوالة دولية',
            style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: _blue,
          elevation: 0,
          leading: IconButton(
            tooltip: 'رجوع',
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        ),
        body: Obx(() {
          if (controller.isFetchingData.value) {
            return const Center(child: CircularProgressIndicator(color: _blue));
          }

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── قسم المبلغ ──
                  _sectionTitle('بيانات المبلغ', isDark),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: FPAuthField(
                          label: 'المبلغ',
                          hint: 'مثال: 500',
                          controller: controller.amountController,
                          fieldKey: _amountKey,
                          focusNode: _amountFocus,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9٠-٩.,٫٬]')),
                          ],
                          validator: FPValidators.amount,
                          accent: _blue,
                          fill: context.theme.cardColor,
                          radius: 10,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: FPAuthDropdown<int>(
                          label: 'عملة الإرسال',
                          hint: 'العملة',
                          fieldKey: _sendCurrencyKey,
                          value: controller.selectedSendCurrency.value,
                          items: _idItems(controller.currencies, isDark),
                          validator:
                          FPValidators.selected<int>('اختر عملة الإرسال'),
                          onChanged: (val) =>
                          controller.selectedSendCurrency.value = val,
                          accent: _blue,
                          fill: context.theme.cardColor,
                          radius: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── بطاقة القيمة بالدولار ──
                  Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(isDark ? 0.15 : 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border:
                      Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'القيمة الفعّالة بالدولار:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 14),
                            ),
                            Text(
                              '${controller.equivalentUsd.value} USD',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                        if (controller.appliedRateLabel.value.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            controller.appliedRateLabel.value,
                            style: TextStyle(
                                fontSize: 11, color: Colors.green.shade700),
                          ),
                        ],
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),

                  FPAuthDropdown<int>(
                    label: 'عملة الاستلام (للمستلم)',
                    hint: 'اختر العملة التي سيستلم بها',
                    fieldKey: _receiveCurrencyKey,
                    value: controller.selectedReceiveCurrency.value,
                    items: _idItems(controller.receiveCurrencyOptions, isDark),
                    validator: FPValidators.selected<int>('اختر عملة الاستلام'),
                    onChanged: (val) =>
                    controller.selectedReceiveCurrency.value = val,
                    accent: _blue,
                    fill: context.theme.cardColor,
                    radius: 10,
                  ),
                  const SizedBox(height: 12),

                  // ── مبلغ عملة الاستلام ──
                  Obx(() {
                    if (controller.receiveEquivalent.value == '0.00' ||
                        controller.selectedReceiveCurrency.value == null) {
                      return const SizedBox.shrink();
                    }
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(isDark ? 0.15 : 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border:
                        Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المبلغ بعملة الاستلام:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 14),
                          ),
                          Text(
                            '${controller.receiveEquivalent.value} ${controller.receiveRateLabel.value}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.orange),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),

                  // ── قسم الوجهة ──
                  _sectionTitle('بيانات الوجهة', isDark),
                  const SizedBox(height: 16),

                  FPAuthDropdown<int>(
                    label: 'دولة الاستلام',
                    hint: 'اختر الدولة الوجهة',
                    fieldKey: _countryKey,
                    value: controller.selectedCountry.value,
                    items: _idItems(controller.countries, isDark),
                    validator: FPValidators.selected<int>('اختر دولة الاستلام'),
                    onChanged: (val) {
                      controller.onCountryChanged(val);
                      // المدينة السابقة لم تعد صالحة: صفّر حقلها وخطأه بعد إعادة البناء
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _cityKey.currentState?.reset();
                      });
                    },
                    accent: _blue,
                    fill: context.theme.cardColor,
                    radius: 10,
                  ),
                  const SizedBox(height: 16),

                  Obx(() => FPAuthDropdown<String>(
                    label: 'مدينة الاستلام',
                    hint: 'اختر المدينة',
                    fieldKey: _cityKey,
                    value: controller.selectedCity.value,
                    items: controller.availableCities
                        .map((city) => DropdownMenuItem<String>(
                      value: city,
                      child: Text(city,
                          style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87)),
                    ))
                        .toList(),
                    validator: (v) {
                      if (v != null) return null;
                      return controller.selectedCountry.value == null
                          ? 'اختر دولة الاستلام أولًا ثم المدينة'
                          : 'اختر مدينة الاستلام';
                    },
                    onChanged: (val) => controller.selectedCity.value = val,
                    accent: _blue,
                    fill: context.theme.cardColor,
                    radius: 10,
                  )),
                  const SizedBox(height: 16),

                  // ── اختيار المكتب (اختياري) ──
                  Divider(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                      thickness: 1),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14,
                          color:
                          isDark ? Colors.white38 : Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'اختياري — حدّد مكتب الاستلام إن كنت تعرفه',
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Obx(() => FPAuthDropdown<int>(
                    label: 'مكتب الاستلام (اختياري)',
                    hint: 'اختر المكتب',
                    value: controller.selectedOffice.value,
                    items: _idItems(controller.offices, isDark),
                    onChanged: (val) =>
                    controller.selectedOffice.value = val,
                    accent: _blue,
                    fill: context.theme.cardColor,
                    radius: 10,
                  )),

                  // ── زر إلغاء تحديد المكتب ──
                  Obx(() => controller.selectedOffice.value != null
                      ? Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                      controller.selectedOffice.value = null,
                      icon: const Icon(Icons.close,
                          size: 14, color: Colors.redAccent),
                      label: const Text('إلغاء تحديد المكتب',
                          style: TextStyle(
                              fontSize: 12, color: Colors.redAccent)),
                    ),
                  )
                      : const SizedBox.shrink()),

                  const SizedBox(height: 32),

                  // ── قسم المستلم ──
                  _sectionTitle('بيانات المستلم', isDark),
                  const SizedBox(height: 16),

                  FPAuthField(
                    label: 'اسم المستلم الكامل',
                    hint: 'أدخل اسم المستلم الثلاثي',
                    icon: Icons.person_outline,
                    controller: controller.receiverNameController,
                    fieldKey: _nameKey,
                    focusNode: _nameFocus,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        FPValidators.fullName(v, who: 'اسم المستلم'),
                    onSubmitted: (_) => _phoneFocus.requestFocus(),
                    accent: _blue,
                    fill: context.theme.cardColor,
                    radius: 10,
                  ),
                  const SizedBox(height: 16),

                  // ✅ حقل هاتف المستلم الدولي
                  _buildPhoneField(context, isDark),
                  const SizedBox(height: 40),

                  // ── زر الإرسال ──
                  Obx(() {
                    final bool loading = controller.isLoading.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          disabledBackgroundColor: _blue.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          elevation: 5,
                        ),
                        child: AnimatedSwitcher(
                          duration: FPMotion.fast,
                          child: loading
                              ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                              : const Text(
                            'إرسال الحوالة الدولية',
                            key: ValueKey('label'),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Tajawal'),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ✅ حقل الهاتف الدولي للمستلم (طول الرقم يُتحقق منه حسب الدولة داخل المكتبة)
  Widget _buildPhoneField(BuildContext context, bool isDark) {
    final Color err = fpErrorColor(isDark);
    OutlineInputBorder border(Color c, [double w = 1.0]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c, width: w));

    return Column(
      key: _phoneAnchor,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(
            'رقم هاتف المستلم',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: IntlPhoneField(
            controller: controller.receiverPhoneController,
            focusNode: _phoneFocus,
            initialCountryCode: 'SY',
            keyboardType: TextInputType.phone,
            invalidNumberMessage:
            'رقم الهاتف غير صالح لهذه الدولة، تحقق من عدد الأرقام',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            dropdownTextStyle:
            TextStyle(color: isDark ? Colors.white : Colors.black87),
            dropdownIcon: Icon(Icons.arrow_drop_down,
                color: isDark ? Colors.white54 : Colors.grey),
            decoration: InputDecoration(
              hintText: '912 345 678',
              hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                  fontSize: 13),
              filled: true,
              fillColor: context.theme.cardColor,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorMaxLines: 3,
              errorStyle: TextStyle(
                  color: err,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600),
              border: border(context.theme.dividerColor),
              enabledBorder: border(context.theme.dividerColor),
              focusedBorder: border(_blue, 1.5),
              errorBorder: border(err, 1.5),
              focusedErrorBorder: border(err, 2.0),
            ),
            onChanged: (phone) {
              controller.setReceiverPhone(phone.completeNumber);
            },
            onCountryChanged: (country) {
              final current = controller.receiverPhoneController.text;
              if (current.isNotEmpty) {
                controller.setReceiverPhone('+${country.dialCode}$current');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, bool isDark) => Text(
    title,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.blue.shade300 : _blue,
    ),
  );

  List<DropdownMenuItem<int>> _idItems(
      List<Map<String, dynamic>> items, bool isDark) {
    return items
        .map((item) => DropdownMenuItem<int>(
      value: item['id'],
      child: Text(item['name'],
          style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87)),
    ))
        .toList();
  }
}