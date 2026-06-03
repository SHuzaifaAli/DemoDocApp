import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import 'user_management_screen.dart';
import 'hospital_management_screen.dart';
import 'analytics_screen.dart';

class AdminDashboardScreen extends GetView<AdminController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildManagementSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Total Patients', controller.stats?.totalPatients.toString() ?? '0', Icons.people, Colors.blue),
        _buildStatCard('Total Doctors', controller.stats?.totalDoctors.toString() ?? '0', Icons.medical_services, Colors.green),
        _buildStatCard('Appointments', controller.stats?.totalAppointments.toString() ?? '0', Icons.calendar_today, Colors.orange),
        _buildStatCard('Revenue', '\$${controller.stats?.totalRevenue.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (controller.users.isEmpty && controller.hospitals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No data available to manage', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else ...[
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('User Management'),
            subtitle: Text('${controller.users.length} registered users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.to(() => const UserManagementScreen()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.local_hospital_outlined),
            title: const Text('Hospital Management'),
            subtitle: Text('${controller.hospitals.length} hospitals'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.to(() => const HospitalManagementScreen()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Detailed Reports'),
            subtitle: const Text('View detailed analytics and logs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.to(() => const AnalyticsScreen()),
          ),
        ],
      ],
    );
  }
}
