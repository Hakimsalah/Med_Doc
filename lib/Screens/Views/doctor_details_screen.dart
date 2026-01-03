import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../Models/doctor.dart';
import '../Widgets/doctorList.dart';

class DoctorDetails extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetails({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          doctor.name,
          style: GoogleFonts.poppins(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte docteur avec hauteur limitée
            SizedBox(
              width: double.infinity,
              child: DoctorList(
                doctor: doctor,
                onTap: () {}, // juste pour affichage ici
              ),
            ),
            SizedBox(height: 3.h),

            // Section "About"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About",
                    style: GoogleFonts.poppins(
                        fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    doctor.bio,
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Experience: ${doctor.experience} years",
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Working Hours: ${doctor.workingHours}",
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Working Days: ${doctor.workingDays.join(', ')}",
                    style: GoogleFonts.poppins(fontSize: 14.sp),
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
}
