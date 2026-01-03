// lib/services/medical_evaluation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/medical_evaluation.dart';

class MedicalEvaluationService {
  final CollectionReference _evalCollection =
      FirebaseFirestore.instance.collection('medical_evaluations');

  // Add evaluation
  Future<void> addEvaluation(MedicalEvaluation evaluation) async {
    print('Adding evaluation for appointment: ${evaluation.appointmentId}');
    try {
      await _evalCollection.add(evaluation.toMap());
      print(' Evaluation added successfully');
    } catch (e) {
      print(' ERROR adding evaluation: $e');
      rethrow;
    }
  }

  // Get all evaluations for a doctor (sorted manually)
  Future<List<MedicalEvaluation>> getDoctorEvaluations(String doctorId) async {
    print('=== Getting evaluations for doctor: $doctorId ===');
    
    try {
      // Query WITHOUT orderBy to avoid index requirement
      final snapshot = await _evalCollection
          .where('doctorId', isEqualTo: doctorId)
          .get();

      print(' Found ${snapshot.docs.length} evaluations');

      var evaluations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MedicalEvaluation.fromMap(data);
      }).toList();

      // Sort manually by createdAt (descending - most recent first)
      evaluations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print(' Sorted ${evaluations.length} evaluations');
      return evaluations;
    } catch (e) {
      print(' ERROR getting evaluations: $e');
      return [];
    }
  }

  // Check if evaluation exists for an appointment
  Future<bool> evaluationExists(String appointmentId) async {
    try {
      final snapshot = await _evalCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print(' ERROR checking evaluation: $e');
      return false;
    }
  }

  // Get evaluation by appointment ID
  Future<MedicalEvaluation?> getEvaluationByAppointment(String appointmentId) async {
    try {
      final snapshot = await _evalCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return MedicalEvaluation.fromMap(data);
    } catch (e) {
      print(' ERROR getting evaluation: $e');
      return null;
    }
  }

  // Get evaluations for a specific patient
  Future<List<MedicalEvaluation>> getPatientEvaluations(String patientId) async {
    try {
      final snapshot = await _evalCollection
          .where('patientId', isEqualTo: patientId)
          .get();

      var evaluations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MedicalEvaluation.fromMap(data);
      }).toList();

      // Sort manually by date (descending)
      evaluations.sort((a, b) => b.evaluationDate.compareTo(a.evaluationDate));
      
      return evaluations;
    } catch (e) {
      print(' ERROR getting patient evaluations: $e');
      return [];
    }
  }
}