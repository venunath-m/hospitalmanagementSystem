import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:intl/intl.dart';

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({super.key});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? selectedDoctor;
  DateTimeRange? selectedDateRange;
  List<Map<String, dynamic>> allAppointments = [];
  List<Map<String, dynamic>> filteredAppointments = [];
  String? selectedDoctorId;
  bool isBooking = false;

  final List<String> doctors = ['Dr. A Kumar', 'Dr. S Mehta', 'Dr. N Reddy'];
  void bookAppointment() async {
    setState(() => isBooking = true);
    if (patientNameController.text.isEmpty ||
        contactNumberController.text.isEmpty ||
        selectedDoctor == null) {
      await PopupMessage.show(
        context,
        title: "Missing Information",
        message: "Please fill all fields",
        icon: Icons.error_outline,
        iconColor: Colors.red,
        backgroundColor: Colors.white,
      );
      setState(() => isBooking = false);
      return;
    }

    final newAppointment = {
      'name': patientNameController.text,
      'phone': contactNumberController.text,
      'doctor': selectedDoctor,
      'date': selectedDate,
    };

    setState(() {
      allAppointments.add(newAppointment);
    });

    await PopupMessage.show(
      context,
      title: "Success",
      message: "Appointment booked!",
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
      backgroundColor: Colors.white,
    );

    patientNameController.clear();
    contactNumberController.clear();
    selectedDoctor = null;
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              FlexibleInputField(
                fieldType: FieldType.text,
                controller: patientNameController,
                label: 'Patient Name',
                isRequired: true,
              ),

              const SizedBox(height: 10),

              FlexibleInputField(
                fieldType: FieldType.phone,
                controller: contactNumberController,
                label: 'Contact Number',
                isRequired: true,
              ),

              const SizedBox(height: 10),

              FlexibleDropdown<String>(
                items: doctors,
                selectedId: selectedDoctorId,
                label: 'Select Doctor',
                idSelector: (doc) => doc,
                displaySelector: (doc) => doc,
                onChanged: (val) => setState(() => selectedDoctorId = val),
                hintText: 'Search or type doctor',
              ),

              const SizedBox(height: 10),

              ListTile(
                title: Text(
                  'Appointment Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),

              const SizedBox(height: 20),

              CustomButton(
                label: 'Book Appointment',
                onPressed: isBooking ? () {} : () => bookAppointment(),
                isLoading: isBooking,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
