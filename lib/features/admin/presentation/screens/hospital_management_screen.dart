import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/admin_entities.dart';

class HospitalManagementScreen extends StatelessWidget {
  const HospitalManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHospitalDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hospitals.isEmpty) {
          return const Center(child: Text('No hospitals found.'));
        }

        return ListView.builder(
          itemCount: controller.hospitals.length,
          itemBuilder: (context, index) {
            final hospital = controller.hospitals[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.red),
                title: Text(hospital.name),
                subtitle: Text(hospital.address),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement department management for this hospital
                  Get.snackbar('Coming Soon', 'Department management for ${hospital.name}');
                },
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddHospitalDialog(BuildContext context, AdminController controller) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Hospital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Hospital Name'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                final newHospital = HospitalEntity(
                  id: '', // Backend will generate ID
                  name: nameController.text,
                  address: addressController.text,
                );
                controller.createHospital(newHospital);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
