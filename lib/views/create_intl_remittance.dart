import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controllers/create_intl_remittance_controller.dart';

class CreateIntlRemittanceView extends StatelessWidget {
  const CreateIntlRemittanceView({Key? key}) : super(key: key);

  static const Color _blue = Color(0xFF2980B9);

  @override
  Widget build(BuildContext context) {
    final CreateIntlRemittanceController controller =
    Get.put(CreateIntlRemittanceController());
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(20))),
        ),
        body: Obx(() {
          if (controller.isFetchingData.value) {
            return const Center(
                child: CircularProgressIndicator(color: _blue));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── قسم المبلغ ───────────────────────────────────────────
                _sectionTitle('بيانات المبلغ', isDark),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        context: context,
                        label: 'المبلغ ',
                        hint: 'مثال: 500',
                        icon: null,
                        controller: controller.amountController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildDropdownField(
                        context: context,
                        label: 'عملة الإرسال ',
                        hint: 'العملة',
                        value: controller.selectedSendCurrency.value,
                        items: controller.currencies,
                        onChanged: (val) =>
                        controller.selectedSendCurrency.value = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── بطاقة القيمة بالدولار ─────────────────────────────────
                Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withOpacity(isDark ? 0.15 : 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
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
                      // ── شريحة السعر ──
                      if (controller.appliedRateLabel.value.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          controller.appliedRateLabel.value,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700),
                        ),
                      ],
                    ],
                  ),
                )),
                const SizedBox(height: 16),

                _buildDropdownField(
                  context: context,
                  label: 'عملة الاستلام (للمستلم) ',
                  hint: 'اختر العملة التي سيستلم بها',
                  value: controller.selectedReceiveCurrency.value,
                  items: controller.currencies,
                  onChanged: (val) =>
                  controller.selectedReceiveCurrency.value = val,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(isDark ? 0.15 : 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المبلغ بعملة الاستلام:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14),
                        ),
                        Text(
                          '${controller.receiveEquivalent.value} ${controller.receiveRateLabel.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),

                // ── قسم الوجهة ────────────────────────────────────────────
                _sectionTitle('بيانات الوجهة', isDark),
                const SizedBox(height: 16),

                _buildDropdownField(
                  context: context,
                  label: 'دولة الاستلام ',
                  hint: 'اختر الدولة الوجهة',
                  value: controller.selectedCountry.value,
                  items: controller.countries,
                  onChanged: (val) => controller.onCountryChanged(val),
                ),
                const SizedBox(height: 16),

                Obx(() => _buildStringDropdownField(
                  context: context,
                  label: 'مدينة الاستلام ',
                  hint: 'اختر المدينة',
                  value: controller.selectedCity.value,
                  items: controller.availableCities,
                  onChanged: (val) =>
                  controller.selectedCity.value = val,
                )),
                const SizedBox(height: 16),

                // ✅ ── اختيار المكتب (اختياري) ────────────────────────────
                _sectionDivider(isDark),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14,
                        color: isDark
                            ? Colors.white38
                            : Colors.grey.shade500),
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

                Obx(() => _buildDropdownField(
                  context: context,
                  label: 'مكتب الاستلام (اختياري)',
                  hint: 'اختر المكتب',
                  value: controller.selectedOffice.value,
                  items: controller.offices,
                  onChanged: (val) =>
                  controller.selectedOffice.value = val,
                  isRequired: false,
                )),

                // ── زر إلغاء تحديد المكتب ────────────────────────────────
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
                            fontSize: 12,
                            color: Colors.redAccent)),
                  ),
                )
                    : const SizedBox.shrink()),

                const SizedBox(height: 32),

                // ── قسم المستلم ───────────────────────────────────────────
                _sectionTitle('بيانات المستلم', isDark),
                const SizedBox(height: 16),

                _buildTextField(
                  context: context,
                  label: 'اسم المستلم الكامل ',
                  hint: 'أدخل اسم المستلم الثلاثي',
                  icon: Icons.person_outline,
                  controller: controller.receiverNameController,
                ),
                const SizedBox(height: 16),

                // ✅ حقل هاتف المستلم الدولي
                _buildPhoneField(context, isDark, controller),
                const SizedBox(height: 40),

                // ── زر الإرسال ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.submitTransfer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      disabledBackgroundColor:
                      _blue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12.0)),
                      elevation: 5,
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text(
                      'إرسال الحوالة الدولية',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal'),
                    ),
                  )),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── عنوان القسم ──
  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.blue.shade300 : _blue,
      ),
    );
  }

  // ── فاصل خفيف ──
  Widget _sectionDivider(bool isDark) {
    return Divider(
        color: isDark ? Colors.white12 : Colors.grey.shade200,
        thickness: 1);
  }

  // ✅ حقل الهاتف الدولي للمستلم
  Widget _buildPhoneField(BuildContext context, bool isDark,
      CreateIntlRemittanceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم هاتف المستلم ',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: IntlPhoneField(
            controller: controller.receiverPhoneController,
            initialCountryCode: 'SY',
            keyboardType: TextInputType.phone,
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
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.theme.dividerColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.theme.dividerColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _blue, width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5)),
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

  // ── حقل نصي ──
  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData? icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style:
          TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.theme.cardColor,
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13),
            suffixIcon: icon != null ? Icon(icon, color: _blue) : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                const BorderSide(color: _blue, width: 1.5)),
          ),
        ),
      ],
    );
  }

  // ── Dropdown بـ int (للعملة / الدولة / المكتب) ──
  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String hint,
    required int? value,
    required List<Map<String, dynamic>> items,
    required Function(int?) onChanged,
    bool isRequired = true,
  }) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.theme.cardColor,
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                const BorderSide(color: _blue, width: 1.5)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: _blue),
          items: items
              .map((item) => DropdownMenuItem<int>(
            value: item['id'],
            child: Text(item['name'],
                style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white
                        : Colors.black87)),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ── Dropdown بـ String (للمدينة) ──
  Widget _buildStringDropdownField({
    required BuildContext context,
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.theme.cardColor,
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                const BorderSide(color: _blue, width: 1.5)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: _blue),
          items: items
              .map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item,
                style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white
                        : Colors.black87)),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}