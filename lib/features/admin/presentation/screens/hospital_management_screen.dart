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
                onTap: () => _showDepartmentsDialog(hospital, controller),
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

  void _showDepartmentsDialog(HospitalEntity hospital, AdminController controller) {
    controller.fetchDepartments(hospital.id);
    final nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Departments - ${hospital.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'New Department Name',
                  suffixIcon: Icon(Icons.add),
                ),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    controller.createDepartment(DepartmentEntity(
                      id: '',
                      hospitalId: hospital.id,
                      name: val,
                    ));
                    nameController.clear();
                  }
                },
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Obx(() => controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.departments.isEmpty
                        ? const Text('No departments found')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.departments.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(controller.departments[index].name),
                                dense: true,
                              );
                            },
                          )),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
