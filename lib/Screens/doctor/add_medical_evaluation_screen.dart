// lib/Screens/doctor/add_medical_evaluation_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Models/medical_evaluation.dart';
import '../../services/medical_evaluation_service.dart';

class AddMedicalEvaluationScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  
  const AddMedicalEvaluationScreen({super.key, required this.appointment});

  @override
  State<AddMedicalEvaluationScreen> createState() => _AddMedicalEvaluationScreenState();
}

class _AddMedicalEvaluationScreenState extends State<AddMedicalEvaluationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MedicalEvaluationService();
  
  final _symptomsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> saveEvaluation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final now = DateTime.now();
      final currentUser = FirebaseAuth.instance.currentUser!;
      
      // Parse comma-separated values and filter empty strings
      final symptoms = _symptomsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      
      final medications = _medicationsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final eval = MedicalEvaluation(
        appointmentId: widget.appointment['id'],
        doctorId: currentUser.uid,
        doctorName: widget.appointment['doctorName'] ?? 'Dr. ${currentUser.email}',
        patientId: widget.appointment['patientId'] ?? '',
        patientName: widget.appointment['patientName'] ?? 'Patient',
        patientEmail: widget.appointment['patientEmail'] ?? '',
        evaluationDate: now,
        symptoms: symptoms,
        medications: medications,
        notes: _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _service.addEvaluation(eval);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Évaluation enregistrée avec succès',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'enregistrement: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.appointment['patientName'] ?? 'Patient';
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Nouvelle Évaluation',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF03BE96),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Patient Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF03BE96),
                      const Color(0xFF03BE96).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: const Color(0xFF03BE96),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      patientName,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Évaluation médicale',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Symptoms Section
                    _buildSectionTitle('Symptômes', Icons.medical_information),
                    SizedBox(height: 1.h),
                    _buildTextField(
                      controller: _symptomsController,
                      label: 'Symptômes du patient',
                      hint: 'Ex: Fièvre, Toux, Fatigue',
                      icon: Icons.sick_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer au moins un symptôme';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Séparez les symptômes par des virgules',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Medications Section
                    _buildSectionTitle('Traitement', Icons.medication),
                    SizedBox(height: 1.h),
                    _buildTextField(
                      controller: _medicationsController,
                      label: 'Médicaments prescrits',
                      hint: 'Ex: Paracétamol 500mg, Ibuprofène 400mg',
                      icon: Icons.local_pharmacy_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer au moins un médicament';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Séparez les médicaments par des virgules',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Notes Section
                    _buildSectionTitle('Notes Médicales', Icons.note_alt),
                    SizedBox(height: 1.h),
                    _buildTextField(
                      controller: _notesController,
                      label: 'Notes et observations',
                      hint: 'Observations complémentaires, recommandations...',
                      icon: Icons.edit_note,
                      maxLines: 5,
                    ),

                    SizedBox(height: 4.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveEvaluation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03BE96),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: isSaving
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save, size: 24),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Enregistrer l\'évaluation',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF03BE96)),
        SizedBox(width: 2.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.inter(fontSize: 15.sp),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFF03BE96),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFF03BE96)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
          errorStyle: GoogleFonts.inter(fontSize: 11.sp),
        ),
      ),
    );
  }
}