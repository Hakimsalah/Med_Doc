import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final String id;
  final String patientName;
  final String email;
  final String phone;
  final String socialSecurityNumber;
  final String medicalHistory;
  final DateTime createdAt;
  final String doctorId;

  MedicalRecord({
    required this.id,
    required this.patientName,
    required this.email,
    required this.phone,
    required this.socialSecurityNumber,
    required this.medicalHistory,
    required this.createdAt,
    required this.doctorId,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> data, String id) {
    DateTime parsedDate = DateTime.now();
    
    try {
      final createdAtField = data['createdAt'];
      
      if (createdAtField != null) {
        if (createdAtField is Timestamp) {
          parsedDate = createdAtField.toDate();
        } else if (createdAtField is DateTime) {
          parsedDate = createdAtField;
        } else {
          // Try dynamic conversion
          parsedDate = (createdAtField as dynamic).toDate();
        }
      }
    } catch (e) {
      print('Warning: Could not parse createdAt, using current time: $e');
      parsedDate = DateTime.now();
    }
    
    return MedicalRecord(
      id: id,
      patientName: data['patientName'] ?? 'Patient',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      socialSecurityNumber: data['socialSecurityNumber'] ?? '',
      medicalHistory: data['medicalHistory'] ?? '',
      createdAt: parsedDate,
      doctorId: data['doctorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'email': email,
      'phone': phone,
      'socialSecurityNumber': socialSecurityNumber,
      'medicalHistory': medicalHistory,
      'createdAt': createdAt, // Keep as DateTime for backward compatibility
      'doctorId': doctorId,
    };
  }
}