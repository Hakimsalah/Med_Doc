import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../Models/medical_record.dart';
import '../../services/medical_record_service.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  const AddMedicalRecordScreen({super.key});

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MedicalRecordService();

  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController socialSecurityController = TextEditingController();
  final TextEditingController medicalHistoryController = TextEditingController();

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF03BE96),
        title: Text('Ajouter Dossier Médical', style: GoogleFonts.inter()),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('Nom du patient', patientNameController),
              buildTextField('Email', emailController),
              buildTextField('Téléphone', phoneController),
              buildTextField('Numéro de sécurité sociale', socialSecurityController),
              buildTextField('Historique médical', medicalHistoryController, maxLines: 4),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: isSaving ? null : saveRecord,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03BE96)),
                child: Text(isSaving ? 'Enregistrement...' : 'Ajouter', style: GoogleFonts.inter(fontSize: 16.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final record = MedicalRecord(
      id: '',
      patientName: patientNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      socialSecurityNumber: socialSecurityController.text.trim(),
      medicalHistory: medicalHistoryController.text.trim(),
      createdAt: DateTime.now(),
      doctorId: FirebaseAuth.instance.currentUser!.uid,
    );

    await _service.addRecord(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dossier ajouté avec succès')),
      );
      Navigator.pop(context);
    }
  }
}
