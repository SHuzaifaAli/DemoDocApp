import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';
import 'availability_management_screen.dart';

class DoctorDashboardScreen extends GetView<DoctorController> {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
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
                _buildActionButtons(),
                const SizedBox(height: 24),
                if (controller.upcomingEvents.isNotEmpty) ...[
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildUpcomingEventsSection(),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'All Appointments',
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionCard(Icons.calendar_month, 'Availability', () => Get.to(() => const AvailabilityManagementScreen())),
        _buildActionCard(Icons.history, 'History', () {}),
        _buildActionCard(Icons.medical_services, 'Records', () {}),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.teal, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

  Widget _buildUpcomingEventsSection() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.upcomingEvents.length,
        itemBuilder: (context, index) {
          final event = controller.upcomingEvents[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.patientName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Icon(Icons.video_call, color: Colors.white),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Tele-consultation',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today, ${event.appointmentTime.hour}:${event.appointmentTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  onPressed: () => _showReschedulePicker(context, appointment.id),
                ),
                PopupMenuButton<String>(
                  onSelected: (status) => controller.updateStatus(appointment.id, status),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                    const PopupMenuItem(value: 'completed', child: Text('Complete')),
                    const PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                  ],
                  child: Chip(
                    label: Text(appointment.status),
                    backgroundColor: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
            onTap: () {
              // Navigate to patient detail/medical records
            },
          ),
        );
      },
    );
  }

  void _showReschedulePicker(BuildContext context, String appointmentId) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final newTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        controller.reschedule(appointmentId, newTime);
      }
    }
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
