// lib/screens/doctor/medical_evaluations_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../services/medical_evaluation_service.dart';
import 'add_medical_evaluation_screen.dart';

class MedicalEvaluationsScreen extends StatefulWidget {
  const MedicalEvaluationsScreen({super.key});

  @override
  State<MedicalEvaluationsScreen> createState() => _MedicalEvaluationsScreenState();
}

class _MedicalEvaluationsScreenState extends State<MedicalEvaluationsScreen> {
  late final String doctorId;
  final _evalService = MedicalEvaluationService();

  bool isLoading = true;
  List<Map<String, dynamic>> completedAppointments = [];

  @override
  void initState() {
    super.initState();
    doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (doctorId.isNotEmpty) {
      loadCompletedAppointments();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadCompletedAppointments() async {
    try {
      setState(() => isLoading = true);

      // Fetch completed appointments WITHOUT orderBy to avoid index requirement
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Convert to list and sort manually
      var appointments = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort manually by date (descending - most recent first)
      appointments.sort((a, b) {
        final dateA = a['date'];
        final dateB = b['date'];

        DateTime? dateTimeA;
        DateTime? dateTimeB;

        if (dateA is Timestamp) {
          dateTimeA = dateA.toDate();
        } else if (dateA is DateTime) {
          dateTimeA = dateA;
        }

        if (dateB is Timestamp) {
          dateTimeB = dateB.toDate();
        } else if (dateB is DateTime) {
          dateTimeB = dateB;
        }

        if (dateTimeA == null && dateTimeB == null) return 0;
        if (dateTimeA == null) return 1;
        if (dateTimeB == null) return -1;

        return dateTimeB.compareTo(dateTimeA);
      });

      if (mounted) {
        setState(() {
          completedAppointments = appointments;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading completed appointments: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'Date inconnue';
      }
      return DateFormat('dd MMM yyyy à HH:mm').format(dateTime);
    } catch (e) {
      return 'Date inconnue';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (doctorId.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Évaluations Médicales',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF03BE96),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
              SizedBox(height: 2.h),
              Text(
                'Erreur: Utilisateur non connecté',
                style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Évaluations Médicales',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF03BE96),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF03BE96)),
            )
          : RefreshIndicator(
              color: const Color(0xFF03BE96),
              onRefresh: loadCompletedAppointments,
              child: completedAppointments.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        // Stats Header
                        Container(
                          margin: EdgeInsets.all(4.w),
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF03BE96),
                                const Color(0xFF03BE96).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF03BE96).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                Icons.assignment_turned_in,
                                '${completedAppointments.length}',
                                'Consultations',
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              FutureBuilder<int>(
                                future: _getEvaluatedCount(),
                                builder: (context, snapshot) {
                                  final count = snapshot.data ?? 0;
                                  return _buildStatItem(
                                    Icons.check_circle,
                                    '$count',
                                    'Évaluées',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // List
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            itemCount: completedAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = completedAppointments[index];
                              return _buildAppointmentCard(appointment);
                            },
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Future<int> _getEvaluatedCount() async {
    int count = 0;
    for (var appointment in completedAppointments) {
      final exists = await _evalService.evaluationExists(appointment['id']);
      if (exists) count++;
    }
    return count;
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final patientName = appointment['patientName'] ?? 'Patient';
    final reason = appointment['reason'] ?? 'Consultation';
    final date = appointment['date'];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03BE96).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.userDoctor,
                    color: Color(0xFF03BE96),
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: GoogleFonts.inter(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        _formatDate(date),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Icon(Icons.medical_services_outlined,
                    size: 16, color: Colors.grey[600]),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    reason,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            FutureBuilder<bool>(
              future: _evalService.evaluationExists(appointment['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final exists = snapshot.data ?? false;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: exists
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddMedicalEvaluationScreen(
                                  appointment: appointment,
                                ),
                              ),
                            ).then((_) => loadCompletedAppointments());
                          },
                    icon: Icon(
                        exists ? Icons.check_circle : Icons.add_circle_outline),
                    label: Text(
                      exists ? 'Évaluation complétée' : 'Ajouter une évaluation',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          exists ? Colors.grey[400] : const Color(0xFF03BE96),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: exists ? 0 : 2,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 15.h),
        Icon(
          Icons.assignment_outlined,
          size: 100,
          color: Colors.grey[300],
        ),
        SizedBox(height: 3.h),
        Center(
          child: Text(
            'Aucune consultation terminée',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              'Les consultations terminées apparaîtront ici pour évaluation',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}