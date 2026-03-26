import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_remittance_controller.dart';

class CreateRemittanceView extends StatelessWidget {
  const CreateRemittanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CreateRemittanceController controller = Get.put(CreateRemittanceController());
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
          backgroundColor: const Color(0xFFA64D04),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        
        // ==========================================
        // 🚀 زر الدعم الفني (تم إصلاح الخطأ)
        // ==========================================
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     Get.snackbar(
        //       'الدعم الفني', 
        //       'سيتم تفعيل خدمة الدعم الفني قريباً',
        //       backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        //       colorText: isDark ? Colors.white : Colors.black,
        //     );
        //   },
        //   backgroundColor: const Color(0xFFA64D04),
        //   icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
        //   label: const Text(
        //     'مساعدة',
        //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        //   ),
        //   elevation: 4, 
        // ),
        // ==========================================

        body: Obx(() {
          if (controller.isFetchingData.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFA64D04)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بيانات المبلغ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.orange.shade300 : const Color(0xFFA64D04))), 
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        context: context, 
                        label: "المبلغ *",
                        hint: "مثال: 500",
                        icon: Icons.attach_money,
                        controller: controller.amountController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildDropdownField(
                        context: context, 
                        label: "عملة الإرسال *",
                        hint: "العملة",
                        value: controller.selectedSendCurrency.value,
                        items: controller.currencies,
                        onChanged: (val) => controller.selectedSendCurrency.value = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDark ? 0.15 : 0.05), 
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                          "القيمة الفعّالة بالدولار:",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)
                      ),
                      Text(
                          "${controller.equivalentUsd.value} USD",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),

                _buildDropdownField(
                  context: context, 
                  label: "عملة الاستلام (للمستلم) *",
                  hint: "اختر العملة التي سيستلم بها",
                  value: controller.selectedReceiveCurrency.value,
                  items: controller.currencies,
                  onChanged: (val) => controller.selectedReceiveCurrency.value = val,
                ),
                const SizedBox(height: 32),

                Text('بيانات الوجهة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.orange.shade300 : const Color(0xFFA64D04))), 
                const SizedBox(height: 16),

                _buildDropdownField(
                  context: context, 
                  label: "مكتب الاستلام *",
                  hint: "اختر المكتب الوجهة",
                  value: controller.selectedOffice.value,
                  items: controller.offices,
                  onChanged: (val) => controller.selectedOffice.value = val,
                ),
                const SizedBox(height: 16),

                // _buildDropdownField(
                //   context: context, 
                //   label: "وكيل الاستلام *",
                //   hint: "اختر الوكيل المسؤول",
                //   value: controller.selectedAgent.value,
                //   items: controller.agents,
                //   onChanged: (val) => controller.selectedAgent.value = val,
                // ),
                const SizedBox(height: 32),

                Text('بيانات المستلم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.orange.shade300 : const Color(0xFFA64D04))), 
                const SizedBox(height: 16),

                _buildTextField(
                  context: context, 
                  label: "اسم المستلم الكامل *",
                  hint: "أدخل اسم المستلم الثلاثي",
                  icon: Icons.person_outline,
                  controller: controller.receiverNameController,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  context: context, 
                  label: "رقم هاتف المستلم *",
                  hint: "أدخل رقم هاتف المستلم",
                  icon: Icons.phone_android,
                  controller: controller.receiverPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => controller.submitTransfer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA64D04),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      elevation: 5,
                    ),
                    child: Obx(() => controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "إرسال الحوالة الآن",
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

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
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
            suffixIcon: Icon(icon, color: const Color(0xFFA64D04)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), 
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), 
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Color(0xFFA64D04), width: 1.5)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), 
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: context.theme.dividerColor)), 
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Color(0xFFA64D04), width: 1.5)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA64D04)),
          items: items.map((Map<String, dynamic> item) {
            return DropdownMenuItem<int>(
              value: item['id'], 
              child: Text(item['name'], style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)), 
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}