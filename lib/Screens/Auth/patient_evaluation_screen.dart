import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PatientEvaluationScreen extends StatelessWidget {
  const PatientEvaluationScreen({super.key});

  // Format date Firestore
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Carte d'évaluation
  Widget buildEvaluationCard(Map<String, dynamic> data) {
    final symptoms = (data['Symptoms'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    final medicaments = (data['medicaments'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    final Timestamp? evaluationDate = data['evaluationDate'];
    final String doctorName = data['doctorName'] ?? '-';
    final String notes = data['notes'] ?? '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Évaluation par $doctorName",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (evaluationDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "📅 ${formatDate(evaluationDate)}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            const Divider(height: 16),

            if (symptoms.isNotEmpty) ...[
              const Text(
                "🩺 Symptômes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...symptoms.map((s) => Text("• $s")),
              const SizedBox(height: 8),
            ],

            if (medicaments.isNotEmpty) ...[
              const Text(
                "💊 Médicaments",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...medicaments.map((m) => Text("• $m")),
              const SizedBox(height: 8),
            ],

            if (notes.isNotEmpty) ...[
              const Text(
                "📝 Notes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(notes),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes évaluations médicales"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medical_evaluations')
            .where('patientId', isEqualTo: user.uid)
            .orderBy('evaluationDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          // 🔄 Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Erreur Firestore (index manquant, etc.)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur Firestore : ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          // 📭 Aucune donnée
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucune évaluation médicale disponible",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return buildEvaluationCard(data);
            },
          );
        },
      ),
    );
  }
}
