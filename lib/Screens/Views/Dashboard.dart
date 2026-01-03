import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../data/doctors_mock.dart';
import '../Widgets/ListDoctorCard.dart';
import '../Widgets/article.dart';
import '../Widgets/safe_asset_image.dart';
import 'doctor_details_screen.dart';
import 'doctor_search.dart';
import 'meet_notifications_screen.dart';
import 'articlePage.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = doctorsMock;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      // ===================== APP BAR =====================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,

        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Welcome Back!",
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where(
                    'patientId',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .where('status', isEqualTo: 'confirmed')
                  .snapshots(),
              builder: (context, snapshot) {
                int notificationCount = 0;

                if (snapshot.hasData) {
                  final now = DateTime.now();
                  notificationCount = snapshot.data!.docs.where((doc) {
                    final date = (doc['date'] as Timestamp).toDate();
                    return date.isAfter(now);
                  }).length;
                }

                return Center(
                  child: badges.Badge(
                    showBadge: notificationCount > 0,
                    badgeContent: Text(
                      notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MeetNotificationsScreen(),
                          ),
                        );
                      },
                      child: SafeAssetImage(
                        "assets/icons/bell.png",
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ===================== BODY =====================
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ===================== SEARCH =====================
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search doctor, drugs, articles...",
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SafeAssetImage(
                        "assets/icons/search.png",
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // ===================== TOP DOCTORS =====================
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Top Doctors",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const DoctorSearch(specialty: "All"),
                        ),
                      );
                    },
                    child: Text(
                      "See all",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: const Color(0xFF03BE96),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              SizedBox(
                height: 28.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 65.w,
                        child: ListDoctorCard(
                          doctor: doctor,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child:
                                    DoctorDetails(doctor: doctor),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 3.h),

              // ===================== ARTICLES =====================
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Health Articles",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const articlePage(),
                        ),
                      );
                    },
                    child: Text(
                      "See all",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: const Color(0xFF03BE96),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              article(
                image: "assets/images/article1.png",
                dateText: "Jun 10, 2021",
                duration: "5 min read",
                mainText:
                    "The 25 Healthiest Fruits You Can Eat, According to a Nutritionist",
              ),

              SizedBox(height: 2.h),

              article(
                image: "assets/images/capsules2.png",
                dateText: "Jun 10, 2020",
                duration: "5 min read",
                mainText:
                    "Comparing the AstraZeneca and Sinovac COVID-19 Vaccines",
              ),

              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}
