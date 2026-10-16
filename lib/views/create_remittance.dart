// =============================================================================
//  lib/views/create_remittance.dart
//  ✅ منطق CreateRemittanceController كما هو
//  ✅ تحقق inline لكل حقل (المبلغ، العملات، المكتب، المحافظة، المستلم، الهاتف)
//  ✅ عند الفشل: تمرير تلقائي وتركيز على أول حقل خاطئ
//  ✅ زر الإرسال يتعطل أثناء التحميل (منع الحوالة المكررة)
//  ✅ بعد الإرسال الناجح تُصفَّر حالة التحقق فلا تظهر أخطاء على نموذج فارغ
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:flashpay/core/app_transitions.dart';
import 'package:flashpay/core/validators.dart';
import 'package:flashpay/views/auth/widgets/fp_auth_field.dart';

import '../controllers/create_remittance_controller.dart';

class CreateRemittanceView extends StatefulWidget {
  const CreateRemittanceView({Key? key}) : super(key: key);

  @override
  State<CreateRemittanceView> createState() => _CreateRemittanceViewState();
}

class _CreateRemittanceViewState extends State<CreateRemittanceView> {
  static const Color _accent = Color(0xFFA64D04);

  final CreateRemittanceController controller =
  Get.put(CreateRemittanceController());

  final _formKey = GlobalKey<FormState>();
  final _amountKey = GlobalKey<FormFieldState<String>>();
  final _sendCurrencyKey = GlobalKey<FormFieldState<int>>();
  final _receiveCurrencyKey = GlobalKey<FormFieldState<int>>();
  final _officeKey = GlobalKey<FormFieldState<int>>();
  final _governorateKey = GlobalKey<FormFieldState<String>>();
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _phoneAnchor = GlobalKey();

  final _amountFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  late final List<GlobalKey<FormFieldState<dynamic>>> _order = [
    _amountKey,
    _sendCurrencyKey,
    _receiveCurrencyKey,
    _officeKey,
    _governorateKey,
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
            'إرسال حوالة',
            style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: _accent,
          elevation: 0,
          leading: IconButton(
            tooltip: 'رجوع',
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Obx(() {
          if (controller.isFetchingData.value) {
            return const Center(
                child: CircularProgressIndicator(color: _accent));
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
                          accent: _accent,
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
                          accent: _accent,
                          fill: context.theme.cardColor,
                          radius: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── بطاقة القيمة بالدولار + الشريحة ──
                  Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(isDark ? 0.15 : 0.05),
                      borderRadius: BorderRadius.circular(12),
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
                                  fontSize: 20,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                        if (controller.appliedRateLabel.value.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.layers_outlined,
                                    size: 14, color: Colors.green),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    controller.appliedRateLabel.value,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
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
                    accent: _accent,
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
                    label: 'مكتب الاستلام',
                    hint: 'اختر المكتب الوجهة',
                    fieldKey: _officeKey,
                    value: controller.selectedOffice.value,
                    items: _idItems(controller.offices, isDark),
                    validator: FPValidators.selected<int>('اختر مكتب الاستلام'),
                    onChanged: (val) => controller.selectedOffice.value = val,
                    accent: _accent,
                    fill: context.theme.cardColor,
                    radius: 10,
                  ),
                  const SizedBox(height: 16),

                  FPAuthDropdown<String>(
                    label: 'المحافظة',
                    hint: 'اختر المحافظة السورية',
                    fieldKey: _governorateKey,
                    value: controller.selectedGovernorate.value,
                    items: CreateRemittanceController.syrianGovernorates
                        .map((gov) => DropdownMenuItem<String>(
                      value: gov,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: _accent),
                          const SizedBox(width: 6),
                          Text(gov,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87)),
                        ],
                      ),
                    ))
                        .toList(),
                    validator: FPValidators.selected<String>('اختر المحافظة'),
                    onChanged: (val) =>
                    controller.selectedGovernorate.value = val,
                    accent: _accent,
                    fill: context.theme.cardColor,
                    radius: 10,
                  ),
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
                    accent: _accent,
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
                          backgroundColor: _accent,
                          disabledBackgroundColor: _accent.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                            'إرسال الحوالة الآن',
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
              focusedBorder: border(_accent, 1.5),
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
      color: isDark ? Colors.orange.shade300 : _accent,
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