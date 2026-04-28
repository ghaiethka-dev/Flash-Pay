// =============================================================================
//  agent_send_remittance_tab.dart  — UPDATED
//  ───────────────────────────────────────────
//  تغييرات v2:
//    • إضافة dropdown "مكتب التسليم" (يجلب /offices)
//    • عملة الاستلام: دولار أو ليرة سورية فقط (ثابتة، لا تُجلب من API)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:flashpay/core/constants.dart';
import '../../../../controllers/agent_create_remittance_controller.dart';

class AgentSendRemittanceTab extends StatelessWidget {
  const AgentSendRemittanceTab({Key? key}) : super(key: key);

  static const Color _accent = Color(0xFFA64D04);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AgentCreateRemittanceController(),
      tag: 'agent_remittance',
    );
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Obx(() {
      if (controller.isFetchingData.value) {
        return const Center(child: CircularProgressIndicator(color: _accent));
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchInitialData(),
        color: _accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── رأس الصفحة ──
              _buildHeader(isDark).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
              const SizedBox(height: 28),

              // ═══════════════════════════════════════════════
              // 1. بيانات المبلغ
              // ═══════════════════════════════════════════════
              _sectionTitle('بيانات المبلغ', isDark).animate().fadeIn(delay: 60.ms),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      context: context,
                      label: '',
                      hint: 'مثال: 500',
                      icon: null,
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 1,
                    child: Obx(() => _buildCurrencyDropdown(
                      context: context,
                      label: 'عملة الإرسال ',
                      hint: 'العملة',
                      value: controller.selectedSendCurrency.value,
                      items: controller.currencies,
                      onChanged: (val) => controller.selectedSendCurrency.value = val,
                      isDark: isDark,
                    )),
                  ),
                ],
              ).animate().fadeIn(delay: 80.ms),

              const SizedBox(height: 14),

              // بطاقة القيمة بالدولار
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
                          'القيمة بالدولار:',
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
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 14),

              // ── عملة الاستلام: دولار أو ليرة فقط ──
              Obx(() => _buildReceiveCurrencyDropdown(
                context: context,
                value: controller.selectedReceiveCurrencyCode.value,
                onChanged: (val) => controller.selectedReceiveCurrencyCode.value = val,
                isDark: isDark,
              )).animate().fadeIn(delay: 120.ms),

              const SizedBox(height: 10),

              // ── مبلغ عملة الاستلام ──
              Obx(() {
                if (controller.receiveEquivalent.value == '0.00' ||
                    controller.selectedReceiveCurrencyCode.value == null) {
                  return const SizedBox.shrink();
                }
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(isDark ? 0.15 : 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المبلغ بعملة الاستلام:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13),
                      ),
                      Text(
                        '${controller.receiveEquivalent.value} ${controller.receiveRateLabel.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════════════
              // 2. بيانات الوجهة (مكتب التسليم + محافظة)
              // ═══════════════════════════════════════════════
              _sectionTitle('بيانات الوجهة', isDark).animate().fadeIn(delay: 140.ms),
              const SizedBox(height: 14),

              // ── مكتب التسليم ──────────────────────────────
              Obx(() => _buildOfficeDropdown(
                context: context,
                value: controller.selectedOfficeId.value,
                offices: controller.offices,
                onChanged: (val) => controller.selectedOfficeId.value = val,
                isDark: isDark,
              )).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 14),

              // ── المحافظة ──────────────────────────────────
              Obx(() => _buildStringDropdownField(
                context: context,
                label: 'المحافظة ',
                hint: 'اختر المحافظة السورية',
                value: controller.selectedGovernorate.value,
                items: AgentCreateRemittanceController.syrianGovernorates,
                onChanged: (val) => controller.selectedGovernorate.value = val,
                isDark: isDark,
              )).animate().fadeIn(delay: 160.ms),

              const SizedBox(height: 28),

              // ═══════════════════════════════════════════════
              // 3. بيانات المستلم
              // ═══════════════════════════════════════════════
              _sectionTitle('بيانات المستلم', isDark).animate().fadeIn(delay: 180.ms),
              const SizedBox(height: 14),

              _buildTextField(
                context: context,
                label: 'اسم المستلم الكامل ',
                hint: 'أدخل اسم المستلم الثلاثي',
                icon: Icons.person_outline,
                controller: controller.receiverNameController,
                isDark: isDark,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 14),

              // ✅ حقل هاتف المستلم الدولي
              _buildPhoneField(context, isDark, controller).animate().fadeIn(delay: 220.ms),

              const SizedBox(height: 36),

              // ── زر الإرسال ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.submitTransfer(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: _accent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 5,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'إرسال الحوالة الآن',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                )),
              ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.06),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  // ── رأس الصفحة ──
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGradient.colors.first.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إرسال حوالة',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                SizedBox(height: 3),
                Text(
                  'اختر المكتب والمبلغ وبيانات المستلم',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) => Text(
    title,
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.orange.shade300 : _accent,
    ),
  );

  // ── dropdown عملة الاستلام (USD / SYP فقط) ──
  Widget _buildReceiveCurrencyDropdown({
    required BuildContext context,
    required String? value,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عملة الاستلام ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor,
          decoration: _inputDeco(context, isDark, 'دولار أمريكي أو ليرة سورية'),
          icon: const Icon(Icons.arrow_drop_down, color: _accent),
          items: AgentCreateRemittanceController.receiveCurrencies
              .map((c) => DropdownMenuItem<String>(
            value: c['code'],
            child: Row(
              children: [
                Icon(
                  c['code'] == 'usd'
                      ? null
                      : null,
                  color: _accent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  c['name']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ── dropdown مكتب التسليم ──
  Widget _buildOfficeDropdown({
    required BuildContext context,
    required int? value,
    required List<Map<String, dynamic>> offices,
    required Function(int?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مكتب التسليم ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor,
          decoration: _inputDeco(context, isDark, 'اختر مكتب التسليم'),
          icon: const Icon(Icons.arrow_drop_down, color: _accent),
          items: offices
              .map((o) => DropdownMenuItem<int>(
            value: o['id'],
            child: Row(
              children: [
                const Icon(Icons.store_outlined, color: _accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    o['name'] ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ── dropdown عملة الإرسال (كل العملات) ──
  Widget _buildCurrencyDropdown({
    required BuildContext context,
    required String label,
    required String hint,
    required int? value,
    required List<Map<String, dynamic>> items,
    required Function(int?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor,
          decoration: _inputDeco(context, isDark, hint),
          icon: const Icon(Icons.arrow_drop_down, color: _accent),
          items: items
              .map((item) => DropdownMenuItem<int>(
            value: item['id'],
            child: Text(
              item['name'],
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87),
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ── dropdown محافظات (String) ──
  Widget _buildStringDropdownField({
    required BuildContext context,
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
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
          decoration: _inputDeco(context, isDark, hint),
          icon: const Icon(Icons.arrow_drop_down, color: _accent),
          items: items
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
                        color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ✅ حقل الهاتف الدولي للمستلم
  Widget _buildPhoneField(BuildContext context, bool isDark,
      AgentCreateRemittanceController controller) {
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
                  borderSide: const BorderSide(color: _accent, width: 1.5)),
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

  // ── حقل نص ──
  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData? icon,
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.theme.cardColor,
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13),
            suffixIcon:
            icon != null ? Icon(icon, color: _accent) : null,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: _accent, width: 1.5)),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(
      BuildContext context, bool isDark, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: context.theme.cardColor,
      hintText: hint,
      hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey.shade400,
          fontSize: 13),
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
          borderSide: const BorderSide(color: _accent, width: 1.5)),
    );
  }
}