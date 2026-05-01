// =============================================================================
//  bank_transfer_tab.dart
//  Flash Pay — Agent Bank Transfer Tab
//  ──────────────────────────────────────
//  تاب إرسال حوالة إلى البنك للوكيل
//  الأموال تذهب إلى super_safe فقط، والسوبر ادمن هو من يوافق
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import 'package:flashpay/core/constants.dart';
import '../../../../controllers/bank_transfer_controller.dart';

class BankTransferTab extends StatelessWidget {
  const BankTransferTab({Key? key}) : super(key: key);

  static const Color _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<BankTransferController>()
        ? Get.find<BankTransferController>()
        : Get.put(BankTransferController());
    final bool isDark = context.theme.brightness == Brightness.dark;
    final Color brand = AppColors.primaryGradient.colors.first;

    return RefreshIndicator(
      onRefresh: () => controller.fetchBankTransfers(),
      color: brand,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── رأس الصفحة ──────────────────────────────────────────────
            _buildHeader(isDark).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),

            const SizedBox(height: 24),

            // ── بطاقة النموذج ────────────────────────────────────────────
            _buildFormCard(context, controller, isDark)
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.06),

            const SizedBox(height: 32),

            // ── عنوان سجل الطلبات ────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 4, height: 20,
                  decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Text(
                  'طلباتي البنكية السابقة',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 14),

            // ── قائمة الطلبات السابقة ────────────────────────────────────
            _BankTransferList(controller: controller),
          ],
        ),
      ),
    );
  }

  // ── رأس الصفحة ──
  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.35),
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
            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحويل بنكي',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                SizedBox(height: 3),
                Text(
                  'الأموال تُحوَّل إلى الصندوق الرئيسي\nوتحتاج موافقة المشرف العام',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── بطاقة النموذج ──
  Widget _buildFormCard(BuildContext context, BankTransferController ctrl, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان النموذج
          Row(
            children: [
              Icon(Icons.send_to_mobile_rounded, color: _blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'بيانات التحويل البنكي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── اسم البنك ──
          _buildField(
            context: context,
            label: 'اسم البنك ',
            hint: 'مثال: بنك سوريا والمهجر',
            icon: Icons.account_balance_outlined,
            controller: ctrl.bankNameController,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // ── رقم الحساب ──
          _buildField(
            context: context,
            label: 'رقم الحساب البنكي ',
            hint: 'أدخل رقم الحساب كاملاً',
            icon: Icons.credit_card_rounded,
            controller: ctrl.accountNumberController,
            keyboardType: TextInputType.number,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // ── الاسم الكامل ──
          _buildField(
            context: context,
            label: 'الاسم الكامل لصاحب الحساب ',
            hint: 'أدخل الاسم الثلاثي',
            icon: Icons.person_outline_rounded,
            controller: ctrl.fullNameController,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildField(
            context: context,
            label: 'اسم المستلم (المستفيد الفعلي) ',
            hint: 'أدخل الاسم الثلاثي للمستلم',
            icon: Icons.person_pin_rounded,
            controller: ctrl.recipientNameController,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // ── رقم الموبايل ──
          _buildField(
            context: context,
            label: 'رقم الموبايل ',
            hint: 'مثال: 0991234567',
            icon: Icons.phone_android_rounded,
            controller: ctrl.phoneController,
            keyboardType: TextInputType.phone,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // ── المبلغ + العملة ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: _buildField(
                  context: context,
                  label: 'المبلغ ',
                  hint: 'أدخل المبلغ',
                  icon: Icons.attach_money_rounded,
                  controller: ctrl.amountController,
                  keyboardType: TextInputType.number,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عملة الإرسال ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButtonFormField<int>(
                      value: ctrl.selectedCurrencyId.value,
                      hint: Text('العملة',
                          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400, fontSize: 13)),
                      items: ctrl.currencies.map((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'] as int,
                          child: Text(
                            c['code']?.toString() ?? c['name']?.toString() ?? '',
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => ctrl.selectedCurrencyId.value = val,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2563EB)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── بطاقة القيمة بالدولار ──
          Obx(() {
            if (ctrl.equivalentUsd.value == '0.00' || ctrl.selectedCurrencyId.value == null) {
              return const SizedBox.shrink();
            }
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 4),
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
                      const Text('القيمة بالدولار:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                      Obx(() => Text(
                        '${ctrl.equivalentUsd.value} USD',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.green),
                      )),
                    ],
                  ),
                  Obx(() {
                    if (ctrl.appliedRateLabel.value.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.layers_outlined, size: 13, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(ctrl.appliedRateLabel.value,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),

          // ── الدولة الوجهة ──
          _buildDropdownField(
            label: 'الدولة الوجهة ',
            icon: Icons.flag_rounded,
            hint: 'اختر الدولة',
            value: ctrl.selectedCountry,
            items: ctrl.countries,
            isDark: isDark,
            onChanged: (val) {
              ctrl.selectedCountry.value = val ?? '';
              ctrl.selectedCity.value = '';
            },
          ),
          const SizedBox(height: 14),

          // ── المدينة الوجهة ──
          Obx(() => ctrl.selectedCountry.value.isEmpty
              ? const SizedBox.shrink()
              : _buildDropdownField(
            label: 'المدينة الوجهة',
            icon: Icons.location_city_rounded,
            hint: 'اختر المدينة',
            value: ctrl.selectedCity,
            items: ctrl.citiesByCountry[ctrl.selectedCountry.value] ?? ['أخرى'],
            isDark: isDark,
            onChanged: (val) => ctrl.selectedCity.value = val ?? '',
          ),
          ),
          const SizedBox(height: 14),

          // ── الملاحظات ──
          _buildField(
            context: context,
            label: 'ملاحظات إضافية (اختياري)',
            hint: 'أي تفاصيل إضافية تريد إرسالها...',
            icon: Icons.notes_rounded,
            controller: ctrl.notesController,
            maxLines: 3,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // ── زر الإرسال ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(() => ElevatedButton(
              onPressed: ctrl.isLoading.value ? null : () => ctrl.submitBankTransfer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                disabledBackgroundColor: _blue.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: ctrl.isLoading.value
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'إرسال طلب التحويل',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  // ── حقل إدخال مشترك ──
  Widget _buildField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9FAFB),
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400, fontSize: 13),
            suffixIcon: maxLines == 1 ? Icon(icon, color: _blue, size: 20) : null,
            prefixIcon: maxLines > 1 ? Icon(icon, color: _blue, size: 20) : null,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
// ── حقل القائمة المنسدلة (Dropdown) ──
Widget _buildDropdownField({
  required String label,
  required IconData icon,
  required String hint,
  required RxString value,
  required List<String> items,
  required bool isDark,
  required Function(String?) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : const Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 8),
      // ✅ بدون Obx لمنع إعادة بناء الـ dropdown عند تغيير القيمة
      // نستخدم ValueKey لإعادة البناء فقط عند الضرورة
      Obx(() {
        final currentValue = value.value.isEmpty ? null : value.value;
        // التحقق أن القيمة موجودة في القائمة
        final validValue = (currentValue != null && items.contains(currentValue))
            ? currentValue
            : null;
        return DropdownButtonFormField<String>(
          key: ValueKey('${label}_${items.length}'),
          value: validValue,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item,
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2563EB)),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFF9FAFB),
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? Colors.white30 : Colors.grey.shade400,
                fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
          dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        );
      }),  // ✅ إغلاق Obx
    ],
  );
}
// ─────────────────────────────────────────────────────────────────────────────
//  قائمة الطلبات السابقة
// ─────────────────────────────────────────────────────────────────────────────

class _BankTransferList extends StatelessWidget {
  final BankTransferController controller;
  const _BankTransferList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Obx(() {
      if (controller.isFetchingTransfers.value) {
        return _shimmerList(isDark, context);
      }

      if (controller.bankTransfers.isEmpty) {
        return _emptyState(isDark);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.bankTransfers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final t = controller.bankTransfers[index];
          return _BankTransferCard(transfer: t, controller: controller, index: index);
        },
      );
    });
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 56,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: 14),
            Text(
              'لا توجد طلبات تحويل سابقة',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerList(bool isDark, BuildContext context) {
    return Column(
      children: List.generate(
        3,
            (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 90,
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  بطاقة طلب بنكي واحد
// ─────────────────────────────────────────────────────────────────────────────

class _BankTransferCard extends StatelessWidget {
  final Map<String, dynamic> transfer;
  final BankTransferController controller;
  final int index;

  const _BankTransferCard({
    required this.transfer,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;
    final String status = transfer['status'] ?? 'pending';
    final Color statusColor = controller.statusColor(status);
    final String statusText = controller.statusLabel(status);

    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(right: BorderSide(color: statusColor, width: 4)),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_rounded, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transfer['bank_name'] ?? 'بنك غير محدد',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transfer['full_name'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'رقم الحساب: ${transfer['account_number'] ?? ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transfer['amount'] ?? '0'} USD',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 * index), duration: 350.ms).slideY(begin: 0.08);
  }
}