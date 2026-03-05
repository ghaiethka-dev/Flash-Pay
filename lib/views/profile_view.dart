import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/profile_controller.dart';
import '../core/constants.dart'; // للوصول للألوان

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حقن المتحكم
    final ProfileController controller = Get.put(ProfileController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        
        body: Obx(() {
          if (controller.isLoading.value && controller.transfersHistory.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryGradient.colors.first));
          }

          // إضافة ميزة السحب للتحديث (Pull to refresh)
          return RefreshIndicator(
            color: AppColors.primaryGradient.colors.first,
            onRefresh: () async {
              await controller.fetchProfileData();
            },
            child: SingleChildScrollView(
              // Physics مهمة جداً لكي يعمل السحب حتى لو كانت الشاشة فارغة أو قصيرة
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(controller),
                  const SizedBox(height: 32),

                  const Text(
                    'سجل الحوالات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  _buildTransfersHistory(controller),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ويدجت بطاقة الملف الشخصي
  Widget _buildProfileCard(ProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Lottie.asset(
              'images/profile.json',
              height: 150,
              repeat: true,
              
            ),
          ),
          const SizedBox(height: 24),

          _buildTextField(label: "الاسم الكامل", icon: Icons.person_outline, controller: controller.nameController),
          const SizedBox(height: 16),
          _buildTextField(label: "البريد الإلكتروني", icon: Icons.email_outlined, controller: controller.emailController, isEmail: true),
          const SizedBox(height: 16),
          _buildTextField(label: "رقم الهاتف", icon: Icons.phone_android, controller: controller.phoneController, isPhone: true),
          const SizedBox(height: 16),
          _buildTextField(label: "كلمة المرور الجديدة (اختياري)", hint: "اتركه فارغاً إذا لم ترغب بتغييره", icon: Icons.lock_outline, controller: controller.passwordController, isPassword: true),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => controller.updateProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGradient.colors.first,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Obx(() => controller.isSaving.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("حفظ التعديلات", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت سجل الحوالات
  Widget _buildTransfersHistory(ProfileController controller) {
    if (controller.transfersHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.history, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text("لا يوجد سجل حوالات حتى الآن", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // لمنع التضارب مع السكرول الرئيسي
      itemCount: controller.transfersHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        var transfer = controller.transfersHistory[index];
        return _buildTransferCard(transfer);
      },
    );
  }

  // بطاقة الحوالة الواحدة
  Widget _buildTransferCard(Map<String, dynamic> transfer) {
    // تحديد لون ونص الحالة بناءً على حالة الحوالة من قاعدة البيانات
   // تحديد لون ونص الحالة بناءً على حالة الحوالة من قاعدة البيانات
    Color statusColor;
    String statusText;

    switch (transfer['status']) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'طلب جديد / قيد المراجعة';
        break;
      case 'approved':
        statusColor = Colors.blue;
        statusText = 'بانتظار الإرسال للمكتب';
        break;
      case 'waiting':
        statusColor = const Color.fromARGB(255, 21, 0, 255);
        statusText = 'بانتظار قبول المكتب';
        break;
      case 'ready':
        statusColor = Colors.purple;
        statusText = 'جاهزة للتسليم';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'مكتملة';
        break;
      default:
        statusColor = Colors.grey;
        statusText = transfer['status'] ?? 'غير معروف';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الحوالة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.compare_arrows_rounded, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          // تفاصيل الحوالة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transfer['receiver_name'] ?? 'مستلم غير معروف',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  transfer['tracking_code'] ?? '#',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          // المبلغ والحالة
          // المبلغ والحالة
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                // هنا نجلب كود العملة، وإذا كان غير متوفر نضع مسافة فارغة لتجنب الأخطاء
                "${transfer['amount']} ${transfer['currency'] != null ? transfer['currency']['code'] : ''}", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ويدجت الحقول النصية (للتعديل)
  Widget _buildTextField({
    required String label,
    String? hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: AppColors.primaryGradient.colors.first, width: 1)),
          ),
        ),
      ],
    );
  }
}