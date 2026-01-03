// lib/Models/medical_evaluation.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalEvaluation {
  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final DateTime evaluationDate;
  final List<String> symptoms;
  final List<String> medications;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalEvaluation({
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.evaluationDate,
    required this.symptoms,
    required this.medications,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'evaluationDate': evaluationDate, // Keep as DateTime for compatibility
      'symptoms': symptoms,
      'medications': medications,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Convert Map to object from Firestore
  factory MedicalEvaluation.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic field, String fieldName) {
      try {
        if (field == null) {
          print('⚠️ $fieldName is null, using now()');
          return DateTime.now();
        } else if (field is Timestamp) {
          return field.toDate();
        } else if (field is DateTime) {
          return field;
        } else {
          print('⚠️ Unexpected $fieldName type: ${field.runtimeType}');
          return DateTime.now();
        }
      } catch (e) {
        print('❌ Error parsing $fieldName: $e');
        return DateTime.now();
      }
    }

    return MedicalEvaluation(
      appointmentId: map['appointmentId']?.toString() ?? '',
      doctorId: map['doctorId']?.toString() ?? '',
      doctorName: map['doctorName']?.toString() ?? 'Docteur',
      patientId: map['patientId']?.toString() ?? '',
      patientName: map['patientName']?.toString() ?? 'Patient',
      patientEmail: map['patientEmail']?.toString() ?? '',
      evaluationDate: parseDate(map['evaluationDate'], 'evaluationDate'),
      symptoms: map['symptoms'] != null 
          ? List<String>.from(map['symptoms']) 
          : [],
      medications: map['medications'] != null 
          ? List<String>.from(map['medications']) 
          : [],
      notes: map['notes']?.toString() ?? '',
      createdAt: parseDate(map['createdAt'], 'createdAt'),
      updatedAt: parseDate(map['updatedAt'], 'updatedAt'),
    );
  }

  @override
  String toString() {
    return 'MedicalEvaluation(appointmentId: $appointmentId, patientName: $patientName, evaluationDate: $evaluationDate)';
  }
}