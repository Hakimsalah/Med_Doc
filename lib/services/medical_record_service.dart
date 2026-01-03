import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/medical_record.dart';

class MedicalRecordService {
  final CollectionReference _recordsCollection =
      FirebaseFirestore.instance.collection('medical_records');

  // TEMPORARY TEST VERSION - Remove orderBy to see if data loads
  Future<List<MedicalRecord>> getDoctorRecords(String doctorId) async {
    print('=== SIMPLE TEST - NO ORDERBY ===');
    print('DoctorId: $doctorId');
    
    try {
      // Query WITHOUT orderBy
      final snapshot = await _recordsCollection
          .where('doctorId', isEqualTo: doctorId)
          .get();
      
      print('✅ Records found: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        print('❌ No records found for this doctorId');
        return [];
      }
      
      var records = snapshot.docs.map((doc) {
        print('Document: ${doc.id}');
        final data = doc.data() as Map<String, dynamic>;
        print('  Patient: ${data['patientName']}');
        return MedicalRecord.fromMap(data, doc.id);
      }).toList();
      
      // Sort manually in code (not in Firestore)
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print('✅ Sorted ${records.length} records');
      
      return records;
    } catch (e) {
      print('❌ ERROR: $e');
      return [];
    }
  }

  Future<void> addRecord(MedicalRecord record) async {
    await _recordsCollection.add(record.toMap());
  }

  Future<MedicalRecord?> getRecordById(String id) async {
    final doc = await _recordsCollection.doc(id).get();
    if (!doc.exists) return null;
    return MedicalRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<Map<String, dynamic>> getDoctorStats(String doctorId) async {
    final records = await getDoctorRecords(doctorId);
    
    final totalPatients = records.length;
    
    final Map<String, int> patientsPerMonth = {};
    for (var record in records) {
      final key = "${record.createdAt.year}-${record.createdAt.month.toString().padLeft(2, '0')}";
      patientsPerMonth[key] = (patientsPerMonth[key] ?? 0) + 1;
    }
    
    final now = DateTime.now();
    final last7DaysVisits = records.where((r) {
      final diff = now.difference(r.createdAt).inDays;
      return diff >= 0 && diff <= 7;
    }).length;

    return {
      'totalPatients': totalPatients,
      'patientsPerMonth': patientsPerMonth,
      'last7DaysVisits': last7DaysVisits,
    };
  }
}