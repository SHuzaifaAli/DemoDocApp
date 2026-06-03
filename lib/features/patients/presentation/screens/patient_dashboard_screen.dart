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
                const Text(
                  'Upcoming Appointments',
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
              color: Colors.blue.withOpacity(0.1),
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
            trailing: Chip(
              label: Text(appointment.status),
              backgroundColor: appointment.status == 'confirmed' ? Colors.green[100] : Colors.orange[100],
            ),
          ),
        );
      },
    );
  }
}
