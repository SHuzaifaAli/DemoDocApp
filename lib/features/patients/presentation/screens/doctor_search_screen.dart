import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_controller.dart';
import '../domain/entities/patient_entity.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final controller = Get.find<PatientController>();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSpecialty;
  String? _selectedHospital;
  final List<DoctorEntity> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Doctors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by doctor name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          if (_selectedSpecialty != null || _selectedHospital != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedSpecialty != null)
                    Chip(
                      label: Text(_selectedSpecialty!),
                      onDeleted: () => setState(() {
                        _selectedSpecialty = null;
                        _performSearch();
                      }),
                    ),
                  if (_selectedHospital != null)
                    Chip(
                      label: const Text('Hospital Selected'),
                      onDeleted: () => setState(() {
                        _selectedHospital = null;
                        _performSearch();
                      }),
                    ),
                ],
              ),
            ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final doctor = _searchResults[index];
                          return _buildDoctorCard(doctor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'No doctors found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('Try adjusting your search or filters', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorEntity doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: doctor.avatarUrl != null ? NetworkImage(doctor.avatarUrl!) : null,
              child: doctor.avatarUrl == null ? const Icon(Icons.person, size: 35) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.fullName}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(doctor.specialty ?? 'General', style: TextStyle(color: Colors.blue.shade700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(doctor.hospitalName ?? 'Hospital', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('\$${(doctor.consultationFee ?? 0.0).toStringAsFixed(2)}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showBookingDialog(doctor),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Book'),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch() async {
    setState(() => _isSearching = true);
    try {
      final results = await controller.searchDoctorsUseCase.execute(
        _searchController.text,
        specialty: _selectedSpecialty,
        hospitalId: _selectedHospital,
      );
      setState(() {
        _searchResults.clear();
        _searchResults.addAll(results);
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to search doctors: ${e.toString()}');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Specialty', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Cardiology', 'Neurology', 'Pediatrics', 'General'].map((s) {
                return ChoiceChip(
                  label: Text(s),
                  selected: _selectedSpecialty == s,
                  onSelected: (selected) {
                    setState(() => _selectedSpecialty = selected ? s : null);
                    Get.back();
                    _performSearch();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(DoctorEntity doctor) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Book with Dr. ${doctor.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a reason for visit:'),
            TextField(controller: reasonController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await controller.bookAppointmentUseCase.execute(
                  Get.find<AuthController>().user!.id,
                  doctor.id,
                  selectedDate,
                  reasonController.text,
                );
                Get.back();
                Get.snackbar('Success', 'Appointment booked successfully');
                controller.fetchData();
              } catch (e) {
                Get.snackbar('Error', 'Failed to book: ${e.toString()}');
              }
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}
