import 'package:emart_app/Screens/Widgets/ListDoctorCard.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../Models/doctor.dart';

import 'doctor_details_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../../data/doctors_mock.dart';

class DoctorSearch extends StatelessWidget {
  final String specialty;

  const DoctorSearch({Key? key, required this.specialty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtrer les docteurs selon la spécialité
    final doctors = specialty == "All"
        ? doctorsMock
        : doctorsMock.where((d) => d.specialty == specialty).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Doctors",
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: doctors.isEmpty
              ? const Center(child: Text("No doctors found"))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.w,
                    mainAxisSpacing: 1.h,
                    childAspectRatio: 1.15, // pour éviter overflow
                  ),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doc = doctors[index];
                    return ListDoctorCard(
                      doctor: doc,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: DoctorDetails(doctor: doc),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
