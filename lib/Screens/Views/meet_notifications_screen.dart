import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // <- important

class MeetNotificationsScreen extends StatelessWidget {
  const MeetNotificationsScreen({super.key});

  // Ouvrir le lien Meet
  Future<void> openMeetLink(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
      );
    }
  }

  // Widget pour chaque notification
  Widget buildMeetNotificationItem(Map<String, dynamic> data, BuildContext context) {
    final DateTime meetDate = (data['date'] as Timestamp).toDate();
    final Duration remaining = meetDate.difference(DateTime.now());

    if (remaining.isNegative) return const SizedBox(); // RDV passé ❌

    String remainingText;
    if (remaining.inHours > 0) {
      remainingText = "${remaining.inHours} h ${remaining.inMinutes % 60} min";
    } else {
      remainingText = "${remaining.inMinutes} min";
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.video_call, color: Colors.green),
        title: const Text(
          "Consultation Google Meet",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "🕒 Heure : ${meetDate.hour}:${meetDate.minute.toString().padLeft(2, '0')}"),
            Text("⏳ Temps restant : $remainingText"),
            const SizedBox(height: 4),
            if (data['meetLink'] != null && data['meetLink'].toString().isNotEmpty)
              GestureDetector(
                onTap: () => openMeetLink(data['meetLink'], context),
                child: Text(
                  data['meetLink'],
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications Google Meet"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: user!.uid)
            .where('status', isEqualTo: 'confirmed')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune notification"));
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return buildMeetNotificationItem(data, context);
            }).toList(),
          );
        },
      ),
    );
  }
}
