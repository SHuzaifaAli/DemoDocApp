import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_controller.dart';

class PatientDashboardScreen extends GetView<PatientController> {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
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
                _buildWelcomeHeader(),
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
                  'Appointment History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildAppointmentsList(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/search-doctors'),
        label: const Text('Book Appointment'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        Text(
          controller.profile?.fullName ?? 'Patient',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionCard(Icons.search, 'Find Doctors', () => Get.toNamed('/search-doctors')),
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
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
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

  void _showCancelDialog(String appointmentId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          TextButton(
            onPressed: () {
              Get.find<PatientController>().cancelAppointment(appointmentId);
              Get.back();
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
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
                colors: [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
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
                      'Dr. ${event.doctorName}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Icon(Icons.video_call, color: Colors.white),
                  ],
                ),
                const Spacer(),
                Text(
                  event.hospitalName,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
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
      return const Center(child: Text('No upcoming appointments'));
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
            title: Text('Dr. ${appointment.doctorName}'),
            subtitle: Text('${appointment.hospitalName} - ${appointment.appointmentTime.toString().split('.')[0]}'),
            trailing: appointment.status == 'pending' || appointment.status == 'confirmed'
                ? IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _showCancelDialog(appointment.id),
                  )
                : Chip(
                    label: Text(appointment.status),
                    backgroundColor: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                  ),
          ),
        );
      },
    );
  }
}
