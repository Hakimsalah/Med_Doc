import 'package:emart_app/Models/doctor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../data/doctors_mock.dart'; // ton modèle Doctor

class list_doctor1 extends StatelessWidget {
  final Doctor doctor; // le modèle complet
  final VoidCallback onTap;

  const list_doctor1({
    Key? key,
    required this.doctor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w, // largeur fixe pour le ListView horizontal
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image ronde du docteur
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(doctor.image),
                  fit: BoxFit.cover,
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
                fontSize: 14.sp,
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
                fontSize: 11.sp,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),

            // Évaluation + Distance
            Row(
              children: [
                // Étoiles + Note
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/icons/star.png",
                        width: 4.w,
                        height: 2.5.h,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        doctor.rating.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Color(0xFF04B378),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),

                // Icône de localisation + distance
                Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                SizedBox(width: 0.5.w),
                Expanded(
                  child: Text(
                    doctor.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
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
