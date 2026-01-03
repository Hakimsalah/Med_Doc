import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../Models/doctor.dart';

class ListDoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const ListDoctorCard({Key? key, required this.doctor, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w, // responsive width
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image ronde avec taille responsive et clip pour éviter overflow
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: Image.asset(
                  doctor.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Si l'image n'existe pas
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 1.h),

            // Nom du docteur
            Text(
              doctor.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 0.5.h),

            // Spécialité
            Text(
              doctor.specialty,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),

            // Évaluation et localisation
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16.sp),
                      SizedBox(width: 1.w),
                      Text(
                        doctor.rating.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                SizedBox(width: 0.5.w),
                Expanded(
                  child: Text(
                    doctor.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
