import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';

class AvailabilityManagementScreen extends StatefulWidget {
  const AvailabilityManagementScreen({super.key});

  @override
  State<AvailabilityManagementScreen> createState() => _AvailabilityManagementScreenState();
}

class _AvailabilityManagementScreenState extends State<AvailabilityManagementScreen> {
  final controller = Get.find<DoctorController>();
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _newSlots = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Availability')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: _addTimeSlot,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _newSlots.length,
                itemBuilder: (context, index) {
                  final slot = _newSlots[index];
                  return Card(
                    child: ListTile(
                      title: Text('${slot['start_time']} - ${slot['end_time']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _newSlots.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAvailability,
                child: const Text('Save Availability'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTimeSlot() async {
    final startTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (startTime == null) return;
    
    final endTime = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute),
    );
    if (endTime == null) return;

    setState(() {
      _newSlots.add({
        'available_date': _selectedDate.toIso8601String().split('T')[0],
        'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
        'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
        'slot_duration_minutes': 30,
      });
    });
  }

  void _saveAvailability() {
    if (_newSlots.isEmpty) {
      Get.snackbar('Error', 'Please add at least one time slot');
      return;
    }
    controller.updateAvailability(_newSlots);
    Get.back();
  }
}
