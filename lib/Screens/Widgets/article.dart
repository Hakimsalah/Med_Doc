import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:emart_app/Screens/Widgets/safe_asset_image.dart';

class article extends StatelessWidget {
  final String mainText;
  final String dateText;
  final String duration;
  final String image;

  article({
    required this.mainText,
    required this.dateText,
    required this.duration,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Container(
        height: 10.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromARGB(255, 231, 231, 231)),
        ),
        child: Row(children: [
          SizedBox(width: 2.w),
          Container(
            height: 7.h,
            width: 18.w,
            child: SafeAssetImage(
              image,
              width: 18.w,
              height: 7.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 0.5.h),
                Row(children: [
                  Flexible(
                    child: Text(
                      dateText,
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, fontWeight: FontWeight.w300),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    duration,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 0, 136, 102),
                    ),
                  ),
                ])
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            height: 5.h,
            width: 10.w,
            child: SafeAssetImage(
              "assets/icons/Bookmark.png",
              width: 10.w,
              height: 5.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 2.w),
        ]),
      ),
    );
  }
}
