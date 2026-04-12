import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_intl_remittance_controller.dart';

class CreateIntlRemittanceView extends StatelessWidget {
  const CreateIntlRemittanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CreateIntlRemittanceController controller = Get.put(CreateIntlRemittanceController());
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈 معرفة الثيم الحالي

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor, // 👈 يتجاوب مع الثيم
        appBar: AppBar(
          title: const Text('إرسال حوالة دولية', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF2980B9),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Get.back()),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        ),
        body: Obx(() {
          if (controller.isFetchingData.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2980B9)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بيانات المبلغ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade300 : const Color(0xFF2980B9))), // 👈
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildTextField(context: context, label: "المبلغ *", hint: "مثال: 500", icon: null, controller: controller.amountController, keyboardType: TextInputType.number, color: const Color(0xFF2980B9))),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: _buildDropdownField(context: context, label: "عملة الإرسال *", hint: "العملة", value: controller.selectedSendCurrency.value, items: controller.currencies, onChanged: (val) => controller.selectedSendCurrency.value = val, color: const Color(0xFF2980B9))),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300), width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(isDark ? 0.15 : 0.05), // 👈
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.3))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("القيمة الفعّالة بالدولار:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                      Text("${controller.equivalentUsd.value} USD", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                _buildDropdownField(context: context, label: "عملة الاستلام (للمستلم) *", hint: "اختر العملة التي سيستلم بها", value: controller.selectedReceiveCurrency.value, items: controller.currencies, onChanged: (val) => controller.selectedReceiveCurrency.value = val, color: const Color(0xFF2980B9)),
                const SizedBox(height: 32),

                Text('بيانات الوجهة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade300 : const Color(0xFF2980B9))), // 👈
                const SizedBox(height: 16),

                _buildDropdownField(context: context, label: "دولة الاستلام *", hint: "اختر الدولة الوجهة", value: controller.selectedCountry.value, items: controller.countries, onChanged: (val) => controller.onCountryChanged(val), color: const Color(0xFF2980B9)),
                const SizedBox(height: 16),

                _buildStringDropdownField(context: context, label: "مدينة الاستلام *", hint: "اختر المدينة", value: controller.selectedCity.value, items: controller.availableCities, onChanged: (val) => controller.selectedCity.value = val, color: const Color(0xFF2980B9)),
                const SizedBox(height: 32),

                Text('بيانات المستلم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade300 : const Color(0xFF2980B9))), // 👈
                const SizedBox(height: 16),
                _buildTextField(context: context, label: "اسم المستلم الكامل *", hint: "أدخل اسم المستلم الثلاثي", icon: Icons.person_outline, controller: controller.receiverNameController, color: const Color(0xFF2980B9)),
                const SizedBox(height: 16),
                _buildTextField(context: context, label: "رقم هاتف المستلم *", hint: "أدخل رقم هاتف المستلم", icon: Icons.phone_android, controller: controller.receiverPhoneController, keyboardType: TextInputType.phone, color: const Color(0xFF2980B9)),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: () => controller.submitTransfer(),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2980B9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), elevation: 5),
                    child: Obx(() => controller.isLoading.value ? const CircularProgressIndicator(color: Colors.white) : const Text("إرسال الحوالة الدولية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Tajawal'))),
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

  Widget _buildTextField({required BuildContext context, required String label, required String hint, required IconData? icon, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, required Color color}) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // 👈
        const SizedBox(height: 8),
        TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87), // 👈
            decoration: InputDecoration(
                filled: true,
                fillColor: context.theme.cardColor, // 👈
                hintText: hint,
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
                suffixIcon: Icon(icon, color: color),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), // 👈
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), // 👈
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: color, width: 1.5))
            )
        ),
      ],
    );
  }

  Widget _buildDropdownField({required BuildContext context, required String label, required String hint, required int? value, required List<Map<String, dynamic>> items, required Function(int?) onChanged, required Color color}) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // 👈
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor, // 👈 لون القائمة المنسدلة من الداخل
          decoration: InputDecoration(
              filled: true,
              fillColor: context.theme.cardColor, // 👈
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), // 👈
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), // 👈
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: color, width: 1.5))
          ),
          icon: Icon(Icons.arrow_drop_down, color: color),
          items: items.map((item) => DropdownMenuItem<int>(
              value: item['id'],
              child: Text(item['name'], style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)) // 👈
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStringDropdownField({required BuildContext context, required String label, required String hint, required String? value, required List<String> items, required Function(String?) onChanged, required Color color}) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // 👈
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor, // 👈
          decoration: InputDecoration(
              filled: true,
              fillColor: context.theme.cardColor, // 👈
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), // 👈
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), // 👈
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: color, width: 1.5))
          ),
          icon: Icon(Icons.arrow_drop_down, color: color),
          items: items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)) // 👈
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}