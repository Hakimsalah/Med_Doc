import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF03BE96),
        elevation: 0,
        title:  Text(
          'Mes Patients',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            color: const Color(0xFF03BE96),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value. toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un patient...',
                hintStyle: TextStyle(color: Colors. white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white. withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:  BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child:  _buildPatientsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore. instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot. hasData || snapshot.data!. docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                SizedBox(height: 2.h),
                Text(
                  'Aucun patient',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Extract unique patients
        Map<String, Map<String, dynamic>> uniquePatients = {};
        for (var doc in snapshot.data!. docs) {
          final data = doc.data() as Map<String, dynamic>;
          final patientId = data['patientId'] ?? '';
          if (patientId.isNotEmpty) {
            if (!uniquePatients.containsKey(patientId)) {
              uniquePatients[patientId] = {
                'id': patientId,
                'name': data['patientName'] ?? 'Patient',
                'email': data['patientEmail'] ?? '',
                'lastVisit': data['date'],
                'appointmentCount': 1,
              };
            } else {
              uniquePatients[patientId]!['appointmentCount']++;
              // Keep the most recent visit
              if ((data['date'] as Timestamp).compareTo(
                    uniquePatients[patientId]!['lastVisit'] as Timestamp,
                  ) >
                  0) {
                uniquePatients[patientId]!['lastVisit'] = data['date'];
              }
            }
          }
        }

        // Filter by search query
        var filteredPatients = uniquePatients.values.where((patient) {
          return patient['name'].toString().toLowerCase().contains(searchQuery) ||
              patient['email'].toString().toLowerCase().contains(searchQuery);
        }).toList();

        // Sort by last visit (most recent first)
        filteredPatients.sort((a, b) {
          return (b['lastVisit'] as Timestamp).compareTo(a['lastVisit'] as Timestamp);
        });

        if (filteredPatients.isEmpty) {
          return Center(
            child: Text(
              'Aucun patient trouvé',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(3.w),
          itemCount: filteredPatients.length,
          itemBuilder: (context, index) {
            return _buildPatientCard(filteredPatients[index]);
          },
        );
      },
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final lastVisit = (patient['lastVisit'] as Timestamp).toDate();
    final daysSinceVisit = DateTime.now().difference(lastVisit).inDays;
    String lastVisitText;

    if (daysSinceVisit == 0) {
      lastVisitText = "Aujourd'hui";
    } else if (daysSinceVisit == 1) {
      lastVisitText = "Hier";
    } else if (daysSinceVisit < 30) {
      lastVisitText = "Il y a $daysSinceVisit jours";
    } else {
      lastVisitText = "Il y a ${(daysSinceVisit / 30).floor()} mois";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color:  Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets. all(3.w),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF03BE96).withOpacity(0.1),
          child: Text(
            patient['name']. toString().substring(0, 1).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF03BE96),
            ),
          ),
        ),
        title: Text(
          patient['name'],
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0.5.h),
            Row(
              children: [
                Icon(Icons.email, size: 14, color: Colors.grey[600]),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    patient['email'],
                    style: GoogleFonts. inter(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color:  Colors.grey[600]),
                SizedBox(width: 1.w),
                Text(
                  lastVisitText,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03BE96).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${patient['appointmentCount']} RDV',
                    style:  GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF03BE96),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            _showPatientDetails(patient);
          },
        ),
      ),
    );
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius. circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller:  scrollController,
            child:  Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF03BE96).withOpacity(0.1),
                      child: Text(
                        patient['name'].toString().substring(0, 1).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF03BE96),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Center(
                    child: Text(
                      patient['name'],
                      style: GoogleFonts.inter(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      patient['email'],
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Historique des rendez-vous',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorId', isEqualTo: user?. uid)
                        .where('patientId', isEqualTo: patient['id'])
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (! snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('Aucun historique');
                      }

                      return Column(
                        children: snapshot. data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final date = (data['date'] as Timestamp).toDate();
                          final status = data['status'] ?? 'unknown';

                          Color statusColor;
                          switch (status) {
                            case 'pending':
                              statusColor = Colors.orange;
                              break;
                            case 'confirmed':
                              statusColor = Colors.blue;
                              break;
                            case 'completed':
                              statusColor = Colors.green;
                              break;
                            case 'rejected':
                              statusColor = Colors.red;
                              break;
                            default:
                              statusColor = Colors.grey;
                          }

                          return Container(
                            margin: EdgeInsets.only(bottom: 1.h),
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment. spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${date.day}/${date. month}/${date.year}',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      data['reason'] ?? 'Consultation',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration:  BoxDecoration(
                                    color: statusColor. withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    status,
                                    style: GoogleFonts.inter(
                                      color: statusColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight. w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}