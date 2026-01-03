import 'package:emart_app/Screens/doctor/doctor_profile_screen.dart';
import 'package:emart_app/Screens/doctor/doctor_appointments_screen.dart';
import 'package:emart_app/Screens/doctor/doctor_dashboard.dart';
import 'package:emart_app/Screens/doctor/doctor_patients_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  int page = 0;

  final List<Widget> pages = const [
    DoctorDashboard(),
    DoctorPatientsScreen(),
    DoctorAppointmentsScreen(),
    DoctorProfileScreen(),
  ];

  final List<IconData> icons = [
    FontAwesomeIcons.house,
    FontAwesomeIcons.userInjured,
    FontAwesomeIcons.calendarCheck,
    FontAwesomeIcons.user,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[page],
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: icons,
        activeIndex: page,
        gapLocation: GapLocation.none,
        height: 70,
        iconSize: 22,
        activeColor: const Color(0xFF03BE96),
        inactiveColor: Colors.grey.shade400,
        onTap:  (index) {
          setState(() {
            page = index;
          });
        },
      ),
    );
  }
}