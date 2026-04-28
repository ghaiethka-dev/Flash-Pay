import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controllers/create_remittance_controller.dart';

class CreateRemittanceView extends StatelessWidget {
  const CreateRemittanceView({Key? key}) : super(key: key);

  static const Color _accent = Color(0xFFA64D04);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateRemittanceController());
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'إرسال حوالة',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: _accent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Obx(() {
          if (controller.isFetchingData.value) {
            return const Center(child: CircularProgressIndicator(color: _accent));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── قسم المبلغ ──
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
                        onChanged: (val) => controller.selectedSendCurrency.value = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── بطاقة القيمة بالدولار + الشريحة ──
                Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDark ? 0.15 : 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'القيمة الفعّالة بالدولار:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                          ),
                          Text(
                            '${controller.equivalentUsd.value} USD',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
                          ),
                        ],
                      ),
                      if (controller.appliedRateLabel.value.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.layers_outlined, size: 14, color: Colors.green),
                              const SizedBox(width: 5),
                              Text(
                                controller.appliedRateLabel.value,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green),
                              ),
                            ],
                          ),
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
                  onChanged: (val) => controller.selectedReceiveCurrency.value = val,
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

                // ── قسم الوجهة ──
                _sectionTitle('بيانات الوجهة', isDark),
                const SizedBox(height: 16),

                _buildDropdownField(
                  context: context,
                  label: 'مكتب الاستلام ',
                  hint: 'اختر المكتب الوجهة',
                  value: controller.selectedOffice.value,
                  items: controller.offices,
                  onChanged: (val) => controller.selectedOffice.value = val,
                ),
                const SizedBox(height: 16),

                _buildStringDropdownField(
                  context: context,
                  label: 'المحافظة ',
                  hint: 'اختر المحافظة السورية',
                  value: controller.selectedGovernorate.value,
                  items: CreateRemittanceController.syrianGovernorates,
                  onChanged: (val) => controller.selectedGovernorate.value = val,
                ),
                const SizedBox(height: 32),

                // ── قسم المستلم ──
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

                // ── زر الإرسال ──
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => controller.submitTransfer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: Obx(() => controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'إرسال الحوالة الآن',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Tajawal'),
                    )),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ✅ حقل الهاتف الدولي للمستلم
  Widget _buildPhoneField(BuildContext context, bool isDark,
      CreateRemittanceController controller) {
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
                  borderSide:
                  const BorderSide(color: _accent, width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  const BorderSide(color: Colors.red, width: 1.5)),
            ),
            onChanged: (phone) {
              controller.setReceiverPhone(phone.completeNumber);
            },
            onCountryChanged: (country) {
              final current = controller.receiverPhoneController.text;
              if (current.isNotEmpty) {
                controller
                    .setReceiverPhone('+${country.dialCode}$current');
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
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.theme.cardColor,
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
            suffixIcon: icon != null ? Icon(icon, color: _accent) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _accent, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String hint,
    required int? value,
    required List<Map<String, dynamic>> items,
    required Function(int?) onChanged,
  }) {
    final bool isDark = context.theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.theme.cardColor,
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _accent, width: 1.5)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: _accent),
          items: items.map((item) => DropdownMenuItem<int>(
            value: item['id'],
            child: Text(item['name'], style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

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
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.theme.cardColor,
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _accent, width: 1.5)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: _accent),
          items: items.map((gov) => DropdownMenuItem<String>(
            value: gov,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: _accent),
                const SizedBox(width: 6),
                Text(gov, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}