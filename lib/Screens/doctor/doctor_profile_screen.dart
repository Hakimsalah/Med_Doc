import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Auth/login.dart';

// ✅ CORRECT CLASS NAME
class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super. key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> doctorData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDoctorData();
  }

  Future<void> loadDoctorData() async {
    if (user == null) return;

    try {
      // Read from 'users' collection
      final docSnap = await FirebaseFirestore. instance
          .collection('users')
          .doc(user! .uid)
          .get();

      if (docSnap. exists) {
        final data = docSnap.data();
        
        // Verify that the user is actually a doctor
        if (data? ['role'] == 'doctor') {
          setState(() {
            doctorData = data ??  {};
            isLoading = false;
          });
        } else {
          // User is not a doctor
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur: Accès non autorisé'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger. of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: ${e.toString()}'),
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
        elevation: 0,
        title:  Text(
          'Mon Profil',
          style:  GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons. edit, color: Colors.white),
            onPressed: () {
              _showEditProfileDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ?  const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child:  Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF03BE96),
                      borderRadius: BorderRadius. only(
                        bottomLeft:  Radius.circular(30),
                        bottomRight: Radius. circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        CircleAvatar(
                          radius:  50,
                          backgroundColor: Colors. white,
                          child: Text(
                            (doctorData['name'] ??  'D')
                                .substring(0, 1)
                                .toUpperCase(),
                            style:  GoogleFonts.inter(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF03BE96),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Dr. ${doctorData['name'] ?? 'Doctor'}',
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          doctorData['specialty'] ?? 'Médecin',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Profile Information
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          'Informations Personnelles',
                          [
                            _buildInfoTile(
                                Icons.email, 'Email', user?. email ?? ''),
                            _buildInfoTile(Icons.phone, 'Téléphone',
                                doctorData['phone'] ?? 'Non renseigné'),
                            _buildInfoTile(Icons.location_on, 'Adresse',
                                doctorData['address'] ?? 'Non renseigné'),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        _buildInfoCard(
                          'Informations Professionnelles',
                          [
                            _buildInfoTile(Icons.medical_services, 'Spécialité',
                                doctorData['specialty'] ?? 'Non renseigné'),
                            _buildInfoTile(Icons. badge, 'N° License',
                                doctorData['licenseNumber'] ?? 'Non renseigné'),
                            _buildInfoTile(Icons.school, 'Formation',
                                doctorData['education'] ?? 'Non renseigné'),
                            _buildInfoTile(Icons. work, 'Expérience',
                                '${doctorData['experience'] ?? '0'} ans'),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        _buildInfoCard(
                          'Disponibilité',
                          [
                            _buildInfoTile(Icons.access_time, 'Horaires',
                                doctorData['workingHours'] ?? 'Non renseigné'),
                            _buildInfoTile(Icons. calendar_today, 'Jours',
                                doctorData['workingDays'] ?? 'Non renseigné'),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        _buildInfoCard(
                          'À propos',
                          [
                            Padding(
                              padding: EdgeInsets.all(3.w),
                              child: Text(
                                doctorData['bio'] ??
                                    'Aucune description disponible',
                                style:  GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color:  Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        // Logout Button
                        SizedBox(
                          width:  double.infinity,
                          height: 6.h,
                          child: ElevatedButton. icon(
                            onPressed:  _handleLogout,
                            icon:  const Icon(Icons.logout),
                            label: Text(
                              'Déconnexion',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight. w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color:  Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFF03BE96).withOpacity(0.1),
              borderRadius: BorderRadius. circular(10),
            ),
            child:  Icon(icon, color: const Color(0xFF03BE96), size: 20),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:  GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: doctorData['name']);
    final phoneCtrl = TextEditingController(text: doctorData['phone']);
    final addressCtrl = TextEditingController(text: doctorData['address']);
    final bioCtrl = TextEditingController(text: doctorData['bio']);
    final specialtyCtrl = TextEditingController(text: doctorData['specialty']);
    final licenseCtrl = TextEditingController(text:  doctorData['licenseNumber']);
    final educationCtrl = TextEditingController(text: doctorData['education']);
    final experienceCtrl = TextEditingController(text: doctorData['experience']?.toString());
    final workingHoursCtrl = TextEditingController(text: doctorData['workingHours']);
    final workingDaysCtrl = TextEditingController(text: doctorData['workingDays']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Modifier le profil',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child:  Column(
            mainAxisSize:  MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: specialtyCtrl,
                decoration:  const InputDecoration(
                  labelText: 'Spécialité',
                  border:  OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: licenseCtrl,
                decoration: const InputDecoration(
                  labelText: 'N° License',
                  border:  OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: educationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Formation',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: experienceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText:  'Expérience (années)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: workingHoursCtrl,
                decoration: const InputDecoration(
                  labelText: 'Horaires (ex: 9h-17h)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: workingDaysCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jours (ex:  Lun-Ven)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'À propos',
                  border:  OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text(
              'Annuler',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateProfile({
                'name': nameCtrl.text,
                'phone':  phoneCtrl.text,
                'address': addressCtrl.text,
                'bio': bioCtrl.text,
                'specialty': specialtyCtrl.text,
                'licenseNumber': licenseCtrl.text,
                'education': educationCtrl. text,
                'experience': int.tryParse(experienceCtrl. text) ?? 0,
                'workingHours': workingHoursCtrl.text,
                'workingDays':  workingDaysCtrl.text,
              });
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03BE96),
            ),
            child: Text(
              'Enregistrer',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(Map<String, dynamic> updates) async {
    if (user == null) return;

    try {
      // Update in 'users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update(updates);

      await loadDoctorData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text('Erreur:  ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Déconnexion',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous vraiment vous déconnecter?',
          style:  GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Déconnexion',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}