import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> patientData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPatientData();
  }

  Future<void> loadPatientData() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists && doc.data()?['role'] == 'patient') {
        setState(() {
          patientData = doc.data()!;
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (e) {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName =
        "${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? ''}";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF03BE96),
        title: Text(
          'Mon Profil',
          style: GoogleFonts.inter(
              fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: 3.h),
                    decoration: const BoxDecoration(
                      color: Color(0xFF03BE96),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            fullName.isNotEmpty
                                ? fullName[0].toUpperCase()
                                : 'P',
                            style: GoogleFonts.inter(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF03BE96),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          fullName,
                          style: GoogleFonts.inter(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          'Patient',
                          style: GoogleFonts.inter(color: Colors.white70),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _buildInfoCard(
                      'Informations personnelles',
                      [
                        _infoTile(Icons.email, 'Email', user?.email ?? ''),
                        _infoTile(Icons.phone, 'Téléphone',
                            patientData['phone']?.toString() ?? ''),
                        _infoTile(Icons.cake, 'Date de naissance',
                            patientData['dateOfBirth'] ?? ''),
                        _infoTile(Icons.location_on, 'Adresse',
                            patientData['address'] ?? ''),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  SizedBox(
                    width: 90.w,
                    height: 6.h,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Déconnexion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _logout,
                    ),
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ),
          Divider(color: Colors.grey[200]),
          ...children
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF03BE96)),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(color: Colors.grey)),
              Text(value,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  void _showEditDialog() {
    final firstNameCtrl =
        TextEditingController(text: patientData['firstName']);
    final lastNameCtrl =
        TextEditingController(text: patientData['lastName']);
    final phoneCtrl =
        TextEditingController(text: patientData['phone']?.toString());
    final addressCtrl =
        TextEditingController(text: patientData['address']);
    final dobCtrl =
        TextEditingController(text: patientData['dateOfBirth']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifier profil'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: firstNameCtrl, decoration: const InputDecoration(labelText: 'Prénom')),
              TextField(controller: lastNameCtrl, decoration: const InputDecoration(labelText: 'Nom')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Téléphone')),
              TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: 'Date de naissance')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Adresse')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .update({
                'firstName': firstNameCtrl.text,
                'lastName': lastNameCtrl.text,
                'phone': phoneCtrl.text,
                'address': addressCtrl.text,
                'dateOfBirth': dobCtrl.text,
              });
              await loadPatientData();
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    }
  }
}
