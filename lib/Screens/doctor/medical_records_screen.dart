import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../Models/medical_record.dart';
import '../../services/medical_record_service.dart';
import 'add_medical_record_screen.dart';
import 'medical_record_detail_screen.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final _service = MedicalRecordService();
  late final String doctorId;

  List<MedicalRecord> records = [];
  List<MedicalRecord> filteredRecords = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (doctorId.isNotEmpty) {
      loadRecords();
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadRecords() async {
    try {
      setState(() => isLoading = true);
      final fetchedRecords = await _service.getDoctorRecords(doctorId);
      
      if (mounted) {
        setState(() {
          records = fetchedRecords;
          filteredRecords = fetchedRecords;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading records: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des dossiers'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRecords = records;
      } else {
        filteredRecords = records.where((record) {
          final nameLower = record.patientName.toLowerCase();
          final emailLower = record.email.toLowerCase();
          final phoneLower = record.phone.toLowerCase();
          final searchLower = query.toLowerCase();
          
          return nameLower.contains(searchLower) ||
                 emailLower.contains(searchLower) ||
                 phoneLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> refreshRecords() async {
    await loadRecords();
    _searchController.clear();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return "Aujourd'hui à ${DateFormat('HH:mm').format(date)}";
    } else if (difference == 1) {
      return "Hier à ${DateFormat('HH:mm').format(date)}";
    } else if (difference < 7) {
      return "Il y a $difference jours";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (doctorId.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: const Color(0xFF03BE96),
          elevation: 0,
          title: Text(
            'Dossiers Patients',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              SizedBox(height: 2.h),
              Text(
                'Erreur: Utilisateur non connecté',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF03BE96),
        elevation: 0,
        title: Text(
          'Dossiers Patients',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(8.h),
          child: Container(
            color: const Color(0xFF03BE96),
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterRecords,
                style: GoogleFonts.inter(fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: 'Rechercher un patient...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            _searchController.clear();
                            _filterRecords('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF03BE96),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF03BE96),
              onRefresh: refreshRecords,
              child: filteredRecords.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        // Stats header
                        Container(
                          margin: EdgeInsets.all(4.w),
                          padding: EdgeInsets.all(3.w),
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
                                Icons.folder_open,
                                '${filteredRecords.length}',
                                'Dossiers',
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                Icons.person_add,
                                '${records.where((r) => DateTime.now().difference(r.createdAt).inDays < 7).length}',
                                'Cette semaine',
                              ),
                            ],
                          ),
                        ),
                        
                        // Records list
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            itemCount: filteredRecords.length,
                            itemBuilder: (context, index) {
                              final record = filteredRecords[index];
                              return _buildRecordCard(record);
                            },
                          ),
                        ),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF03BE96),
        icon: const Icon(Icons.add),
        label: Text(
          'Nouveau',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMedicalRecordScreen(),
            ),
          ).then((_) => refreshRecords());
        },
      ),
    );
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

  Widget _buildRecordCard(MedicalRecord record) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicalRecordDetailScreen(
                  recordId: record.id,
                ),
              ),
            ).then((_) => loadRecords());
          },
          borderRadius: BorderRadius.circular(16),
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
                            record.patientName,
                            style: GoogleFonts.inter(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            _formatDate(record.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildInfoRow(Icons.email_outlined, record.email),
                SizedBox(height: 1.h),
                _buildInfoRow(Icons.phone_outlined, record.phone),
                if (record.socialSecurityNumber.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  _buildInfoRow(
                    Icons.badge_outlined,
                    'N° SS: ${record.socialSecurityNumber}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isEmpty = records.isEmpty;
    final isFiltered = _searchController.text.isNotEmpty;
    
    return ListView(
      children: [
        SizedBox(height: 15.h),
        Icon(
          isEmpty ? Icons.folder_open : Icons.search_off,
          size: 100,
          color: Colors.grey[300],
        ),
        SizedBox(height: 3.h),
        Center(
          child: Text(
            isEmpty
                ? 'Aucun dossier médical'
                : 'Aucun résultat trouvé',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Center(
          child: Text(
            isEmpty
                ? 'Commencez par ajouter votre premier patient'
                : 'Essayez avec un autre terme de recherche',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (isEmpty) ...[
          SizedBox(height: 4.h),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMedicalRecordScreen(),
                  ),
                ).then((_) => refreshRecords());
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Ajouter un patient',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03BE96),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 1.5.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}