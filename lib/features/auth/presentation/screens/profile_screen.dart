import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final fullNameController = TextEditingController(text: controller.user?.fullName);
    final phoneController = TextEditingController(text: controller.user?.phoneNumber);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(controller.user?.email ?? 'N/A'),
              leading: const Icon(Icons.email),
            ),
            ListTile(
              title: const Text('Role'),
              subtitle: Text(controller.user?.role?.toUpperCase() ?? 'N/A'),
              leading: const Icon(Icons.verified_user),
            ),
            const SizedBox(height: 32),
            Obx(() => controller.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.updateProfile({
                        'full_name': fullNameController.text.trim(),
                        'phone_number': phoneController.text.trim(),
                      }),
                      child: const Text('Save Changes'),
                    ),
                  )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => controller.signOut().then((_) => Get.offAllNamed('/login')),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
