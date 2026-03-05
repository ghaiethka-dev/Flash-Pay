import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_remittance_controller.dart';
import '../core/constants.dart'; // للوصول للألوان AppColors

class CreateRemittanceView extends StatelessWidget {
  const CreateRemittanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حقن المتحكم الخاص بصفحة الحوالات
    final CreateRemittanceController controller = Get.put(CreateRemittanceController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'إرسال حوالة',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFA64D04),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: Obx(() {
          // عرض مؤشر تحميل أثناء جلب المكاتب والعملات من السيرفر
          if (controller.isFetchingData.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFA64D04)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === معلومات المبلغ والعملة ===
                const Text('بيانات المبلغ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFA64D04))),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
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
                        label: "العملة *",
                        hint: "العملة",
                        value: controller.selectedCurrency.value,
                        items: controller.currencies,
                        onChanged: (val) => controller.selectedCurrency.value = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // === المربع الأخضر لعرض القيمة بالدولار ===
                Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
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
                const SizedBox(height: 32),

                // === معلومات الوجهة ===
                const Text('بيانات الوجهة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFA64D04))),
                const SizedBox(height: 16),

                _buildDropdownField(
                  label: "مكتب الاستلام *",
                  hint: "اختر المكتب الوجهة",
                  value: controller.selectedOffice.value,
                  items: controller.offices,
                  onChanged: (val) => controller.selectedOffice.value = val,
                ),
                const SizedBox(height: 16),

                _buildDropdownField(
                  label: "وكيل الاستلام *",
                  hint: "اختر الوكيل المسؤول",
                  value: controller.selectedAgent.value,
                  items: controller.agents,
                  onChanged: (val) => controller.selectedAgent.value = val,
                ),
                const SizedBox(height: 32),

                // === معلومات المستلم ===
                const Text('بيانات المستلم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFA64D04))),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "اسم المستلم الكامل *",
                  hint: "أدخل اسم المستلم الثلاثي",
                  icon: Icons.person_outline,
                  controller: controller.receiverNameController,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: "رقم هاتف المستلم *",
                  hint: "أدخل رقم هاتف المستلم",
                  icon: Icons.phone_android,
                  controller: controller.receiverPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 40),

                // === زر الإرسال ===
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

  // ويدجت مساعدة لإنشاء الحقول النصية بتنسيق موحد
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            suffixIcon: Icon(icon, color: const Color(0xFFA64D04)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Color(0xFFA64D04), width: 1.5)),
          ),
        ),
      ],
    );
  }

  // ويدجت مساعدة لإنشاء القوائم المنسدلة (Dropdown) وتعتمد على الـ ID كقيمة (Value)
  Widget _buildDropdownField({
    required String label,
    required String hint,
    required int? value,
    required List<Map<String, dynamic>> items,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Color(0xFFA64D04), width: 1.5)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA64D04)),
          items: items.map((Map<String, dynamic> item) {
            return DropdownMenuItem<int>(
              value: item['id'], // نستخدم الـ ID كقيمة للإرسال إلى السيرفر
              child: Text(item['name'], style: const TextStyle(fontSize: 14)), // ونعرض الاسم للمستخدم
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}