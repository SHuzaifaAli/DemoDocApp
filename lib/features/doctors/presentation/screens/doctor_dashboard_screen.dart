import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';

class DoctorDashboardScreen extends GetView<DoctorController> {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSummary(),
                const SizedBox(height: 24),
                _buildStatsCards(),
                const SizedBox(height: 24),
                const Text(
                  'Today\'s Appointments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildAppointmentsList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileSummary() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: controller.profile?.avatarUrl != null
              ? NetworkImage(controller.profile!.avatarUrl!)
              : null,
          child: controller.profile?.avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dr. ${controller.profile?.fullName ?? 'Doctor'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${controller.profile?.specialty ?? ''} | ${controller.profile?.hospitalName ?? ''}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Appts', controller.appointments.length.toString(), Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Pending', controller.appointments.where((a) => a.status == 'pending').length.toString(), Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Completed', controller.appointments.where((a) => a.status == 'completed').length.toString(), Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((color.alpha * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((color.alpha * 0.3).round())),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (controller.appointments.isEmpty) {
      return const Center(child: Text('No appointments for today'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.appointments.length,
      itemBuilder: (context, index) {
        final appointment = controller.appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(appointment.patientName),
            subtitle: Text(appointment.appointmentTime.toString().split('.')[0]),
            trailing: PopupMenuButton<String>(
              onSelected: (status) => controller.updateStatus(appointment.id, status),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                const PopupMenuItem(value: 'completed', child: Text('Complete')),
                const PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
              ],
              child: Chip(
                label: Text(appointment.status),
                backgroundColor: _getStatusColor(appointment.status).withAlpha((_getStatusColor(appointment.status).alpha * 0.1).round()),
              ),
            ),
            onTap: () {
              // Navigate to patient detail/medical records
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
