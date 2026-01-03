import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'add_medical_record_screen.dart';
import 'medical_records_screen.dart';
import 'doctor_stats_screen.dart';
import 'doctor_medical_evaluations_screen.dart';




class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final user = FirebaseAuth.instance. currentUser;
  String doctorName = '';
  String specialty = '';
  int todayAppointments = 0;
  int totalPatients = 0;
  int pendingRequests = 0;

  @override
  void initState() {
    super.initState();
    loadDoctorData();
  }

  Future<void> loadDoctorData() async {
    if (user == null) return;

    try {
      // Load doctor info from 'users' collection
      final docSnap = await FirebaseFirestore. instance
          .collection('users')
          .doc(user!. uid)
          .get();

      if (docSnap.exists) {
        final data = docSnap.data();
        
        // Verify user is a doctor
        if (data? ['role'] == 'doctor') {
          setState(() {
            doctorName = data?['name'] ?? 'Doctor';
            specialty = data?['specialty'] ?? 'Médecin';
          });
        }
      }

      // Get ALL appointments for this doctor (single simple query)
      final allAppointmentsSnap = await FirebaseFirestore. instance
          .collection('appointments')
          .where('doctorId', isEqualTo:  user!.uid)
          .get();

      // Filter data in memory (no complex queries needed)
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today. month, today.day, 23, 59, 59);

      int todayCount = 0;
      int pendingCount = 0;
      Set<String> uniquePatients = {};

      for (var doc in allAppointmentsSnap.docs) {
        final data = doc.data();
        
        // Count unique patients
        if (data['patientId'] != null) {
          uniquePatients.add(data['patientId']);
        }

        // Count pending requests
        if (data['status'] == 'pending') {
          pendingCount++;
        }

        // Count today's appointments
        if (data['date'] != null) {
          final appointmentDate = (data['date'] as Timestamp).toDate();
          if (appointmentDate.isAfter(startOfDay) && 
              appointmentDate.isBefore(endOfDay)) {
            todayCount++;
          }
        }
      }

      setState(() {
        todayAppointments = todayCount;
        pendingRequests = pendingCount;
        totalPatients = uniquePatients.length;
      });
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text('Erreur de chargement: ${e.toString()}'),
            backgroundColor: Colors. red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF03BE96),
        elevation:  0,
        title:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, Dr. $doctorName',
              style: GoogleFonts.inter(
                fontSize: 18. sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              specialty,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons. notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDoctorData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Rendez-vous\nAujourd\'hui',
                        todayAppointments. toString(),
                        FontAwesomeIcons.calendarDay,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildStatCard(
                        'Demandes\nEn attente',
                        pendingRequests.toString(),
                        FontAwesomeIcons.clock,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child:  _buildStatCard(
                        'Total\nPatients',
                        totalPatients.toString(),
                        FontAwesomeIcons. userInjured,
                        Colors. green,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildStatCard(
                        'Taux de\nPrésence',
                        '92%',
                        FontAwesomeIcons.chartLine,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Quick Actions
                Text(
                  'Actions Rapides',
                  style:  GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickAction(
                      FontAwesomeIcons.calendarPlus,
                      'Créer\nCréneau',
                      Colors.teal,
                    ),
                    _buildQuickAction(
                      FontAwesomeIcons.userPlus,
                      'Nouveau\nPatient',
                      Colors.indigo,
                    ),
                    _buildQuickAction(
                      FontAwesomeIcons.fileLines,
                      'Rapports',
                      Colors.deepOrange,
                    ),
                    _buildQuickAction(
                      FontAwesomeIcons. gear,
                      'Paramètres',
                      Colors.blueGrey,
                    ),
                    _buildQuickAction(
                      FontAwesomeIcons.folderOpen,
                      'Dossiers\nPatients',
                      Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicalRecordsScreen(),
                          ),
                  

                    

                        );
                      },
                    ),
                    _buildQuickAction(
                      Icons.note_alt,
                      'Évaluations des visites',
                      Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MedicalEvaluationsScreen()),
                        );
                      },
                    ),

                    _buildQuickAction(
                    FontAwesomeIcons.chartLine,
                    'Statistiques',
                    Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DoctorStatsScreen()),
                      );
                    },
                  ),



                  ],
                ),

                SizedBox(height: 3.h),

                // Today's Appointments
                Text(
                  'Rendez-vous d\'aujourd\'hui',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildTodayAppointments(),

                SizedBox(height: 3.h),

                // Pending Requests
                Text(
                  'Demandes en attente',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildPendingRequests(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow:  [
          BoxShadow(
            color: Colors.grey. withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius. circular(10),
            ),
            child: FaIcon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
  IconData icon,
  String label,
  Color color, {
  VoidCallback? onTap, // ✅ add this
}) {
  return GestureDetector(
    onTap: onTap ?? () {}, // call it if provided
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: FaIcon(icon, color: color, size: 22.sp),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}


  // ✅ FIXED: Use FutureBuilder instead of StreamBuilder
  Widget _buildTodayAppointments() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getTodayAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (! snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'Aucun rendez-vous aujourd\'hui',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.map((data) {
            return _buildAppointmentCard(data, data['id']);
          }).toList(),
        );
      },
    );
  }

  // ✅ NEW: Get today's appointments as Future
  Future<List<Map<String, dynamic>>> _getTodayAppointments() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo:  user?. uid)
        .get();

    // Filter today's appointments in memory
    final todayDocs = snapshot.docs.where((doc) {
      final data = doc.data();
      if (data['date'] != null) {
        final appointmentDate = (data['date'] as Timestamp).toDate();
        return appointmentDate. isAfter(startOfDay) && 
               appointmentDate. isBefore(endOfDay);
      }
      return false;
    }).toList();

    // Sort by date
    todayDocs.sort((a, b) {
      final aDate = ((a. data())['date'] as Timestamp).toDate();
      final bDate = ((b.data())['date'] as Timestamp).toDate();
      return aDate.compareTo(bDate);
    });

    return todayDocs. map((doc) {
      final data = Map<String, dynamic>.from(doc. data());
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ✅ FIXED: Use FutureBuilder instead of StreamBuilder
  Widget _buildPendingRequests() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getPendingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState. waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (! snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius. circular(15),
            ),
            child: Center(
              child: Text(
                'Aucune demande en attente',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: snapshot. data!.map((data) {
            return _buildRequestCard(data, data['id']);
          }).toList(),
        );
      },
    );
  }

  // ✅ NEW: Get pending requests as Future
  Future<List<Map<String, dynamic>>> _getPendingRequests() async {
    final snapshot = await FirebaseFirestore.instance
        . collection('appointments')
        .where('doctorId', isEqualTo:  user?.uid)
        .where('status', isEqualTo:  'pending')
        .get();

    var docs = snapshot.docs. toList();

    // Sort by createdAt if available
    docs.sort((a, b) {
      final aData = a. data();
      final bData = b.data();
      if (aData['createdAt'] != null && bData['createdAt'] != null) {
        return (bData['createdAt'] as Timestamp)
            .compareTo(aData['createdAt'] as Timestamp);
      }
      return 0;
    });

    // Limit to 5
    final limitedDocs = docs.take(5).toList();

    return limitedDocs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Widget _buildAppointmentCard(Map<String, dynamic> data, String docId) {
    final time = (data['date'] as Timestamp).toDate();
    final timeStr = '${time.hour. toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: const Color(0xFF03BE96).withOpacity(0.1),
              borderRadius: BorderRadius. circular(12),
            ),
            child:  Text(
              timeStr,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF03BE96),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment. start,
              children: [
                Text(
                  data['patientName'] ?? 'Patient',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  data['reason'] ?? 'Consultation',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data, String docId) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange. withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['patientName'] ?? 'Patient',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      data['reason'] ?? 'Consultation',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child:  Text(
                  'En attente',
                  style:  GoogleFonts.inter(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleAppointment(docId, 'confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03BE96),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Accepter',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleAppointment(docId, 'rejected'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors. red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Refuser',
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAppointment(String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': status});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'confirmed' ? 'Rendez-vous accepté' : 'Rendez-vous refusé',
            ),
            backgroundColor: status == 'confirmed' ?  Colors.green : Colors.red,
          ),
        );
      }

      // Reload data to update the UI
      loadDoctorData();
      setState(() {}); // Force rebuild to refresh FutureBuilders
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}