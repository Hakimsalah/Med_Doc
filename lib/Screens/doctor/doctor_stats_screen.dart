import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../services/medical_record_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorStatsScreen extends StatefulWidget {
  const DoctorStatsScreen({super.key});

  @override
  State<DoctorStatsScreen> createState() => _DoctorStatsScreenState();
}

class _DoctorStatsScreenState extends State<DoctorStatsScreen> {
  final _service = MedicalRecordService();
  late final String doctorId;

  bool isLoading = true;
  int totalPatients = 0;
  int last7DaysVisits = 0;
  int last30DaysVisits = 0;
  int todayVisits = 0;
  List<int> last7DaysCounts = List.filled(7, 0);
  Map<String, int> monthlyStats = {};

  @override
  void initState() {
    super.initState();
    doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (doctorId.isNotEmpty) {
      loadStats();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadStats() async {
    try {
      setState(() => isLoading = true);
      
      final stats = await _service.getDoctorStats(doctorId);
      final records = await _service.getDoctorRecords(doctorId);
      
      List<int> counts = List.filled(7, 0);
      final today = DateTime.now();
      int todayCount = 0;
      int last30Count = 0;

      for (var r in records) {
        final diff = today.difference(r.createdAt).inDays;
        
        // Last 7 days for chart
        if (diff >= 0 && diff < 7) {
          counts[6 - diff] += 1;
        }
        
        // Today's visits
        if (diff == 0) {
          todayCount += 1;
        }
        
        // Last 30 days
        if (diff >= 0 && diff < 30) {
          last30Count += 1;
        }
      }

      if (mounted) {
        setState(() {
          totalPatients = stats['totalPatients'] ?? 0;
          last7DaysVisits = stats['last7DaysVisits'] ?? 0;
          last7DaysCounts = counts;
          todayVisits = todayCount;
          last30DaysVisits = last30Count;
          monthlyStats = Map<String, int>.from(stats['patientsPerMonth'] ?? {});
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (doctorId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Statistiques', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF03BE96),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Erreur: Utilisateur non connecté'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Statistiques', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF03BE96),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF03BE96)))
          : RefreshIndicator(
              color: const Color(0xFF03BE96),
              onRefresh: loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 2.h,
                      crossAxisSpacing: 4.w,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          'Total Patients',
                          totalPatients.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Aujourd\'hui',
                          todayVisits.toString(),
                          Icons.today,
                          Colors.green,
                        ),
                        _buildStatCard(
                          '7 Derniers Jours',
                          last7DaysVisits.toString(),
                          Icons.calendar_view_week,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          '30 Derniers Jours',
                          last30DaysVisits.toString(),
                          Icons.calendar_month,
                          Colors.purple,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Chart Section
                    Container(
                      padding: EdgeInsets.all(4.w),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activité des 7 derniers jours',
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                            height: 250,
                            child: last7DaysCounts.every((count) => count == 0)
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.insert_chart_outlined,
                                          size: 60,
                                          color: Colors.grey[300],
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'Aucune visite ces 7 derniers jours',
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: (last7DaysCounts.reduce((a, b) => a > b ? a : b))
                                              .toDouble() +
                                          2,
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              int index = value.toInt();
                                              if (index < 0 || index > 6) {
                                                return const SizedBox();
                                              }
                                              final dayLabel = index == 6 ? 'Aujourd\'hui' : 'J-${6 - index}';
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  dayLabel,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              );
                                            },
                                            interval: 1,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 1,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey[200],
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: List.generate(7, (index) {
                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: last7DaysCounts[index].toDouble(),
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF03BE96),
                                                  const Color(0xFF03BE96).withOpacity(0.7),
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                              width: 24,
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                            )
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 3.h),
                    
                    // Monthly Stats Section
                    if (monthlyStats.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(4.w),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistiques Mensuelles',
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            ...monthlyStats.entries.map((entry) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatMonthYear(entry.key),
                                      style: GoogleFonts.inter(
                                        fontSize: 15.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 0.5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF03BE96).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${entry.value} patients',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF03BE96),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
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
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonthYear(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return key;
    
    final year = parts[0];
    final month = int.parse(parts[1]);
    
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    return '${months[month - 1]} $year';
  }
}