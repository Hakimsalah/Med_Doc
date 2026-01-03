import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState
    extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  final doctorEmailCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();
  final meetLinkCtrl = TextEditingController(); // ✅ Google Meet

  final List<String> statuses = [
    'pending',
    'confirmed',
    'completed',
    'cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    doctorEmailCtrl.dispose();
    reasonCtrl.dispose();
    meetLinkCtrl.dispose();
    super.dispose();
  }

  String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> cancelAppointment(String docId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(docId)
        .update({'status': 'cancelled'});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rendez-vous annulé')),
    );
  }

  Future<void> createAppointment(DateTime selectedDateTime) async {
    final doctorQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: doctorEmailCtrl.text.trim())
        .where('role', isEqualTo: 'doctor')
        .limit(1)
        .get();

    if (doctorQuery.docs.isEmpty) {
      throw 'Docteur introuvable';
    }

    final doctorDoc = doctorQuery.docs.first;

    await FirebaseFirestore.instance.collection('appointments').add({
      'createdAt': FieldValue.serverTimestamp(),
      'date': Timestamp.fromDate(selectedDateTime),
      'patientId': user!.uid,
      'patientEmail': user!.email,
      'patientName': user!.displayName ?? '',
      'doctorId': doctorDoc.id,
      'doctorEmail': doctorDoc['email'],
      'doctorName': doctorDoc['name'],
      'reason': reasonCtrl.text.trim(),
      'meetLink': meetLinkCtrl.text.trim(), // ✅ Google Meet
      'status': 'pending',
    });

    doctorEmailCtrl.clear();
    reasonCtrl.clear();
    meetLinkCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rendez-vous envoyé')),
    );
  }

  Widget buildAppointmentList(String status) {
    final query = FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: user!.uid)
        .where('status', isEqualTo: status)
        .orderBy('date');

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucun rendez-vous'));
        }

        return ListView(
          padding: const EdgeInsets.all(10),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                title: Text(data['doctorName'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Motif : ${data['reason'] ?? '-'}"),
                    Text(
                      "Date : ${formatDate(data['date'])} à ${formatTime(data['date'])}",
                    ),
                    if (data['meetLink'] != null &&
                        data['meetLink'].toString().isNotEmpty)
                      Text(
                        "Google Meet : ${data['meetLink']}",
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    Text(
                      statusLabel(data['status']),
                      style: TextStyle(
                        color: statusColor(data['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: data['status'] == 'pending'
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => cancelAppointment(doc.id),
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> showCreateAppointmentDialog() async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouveau rendez-vous'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: doctorEmailCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Email du docteur'),
                ),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Motif'),
                ),
                TextField(
                  controller: meetLinkCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Lien Google Meet',
                    hintText: 'https://meet.google.com/...',
                    prefixIcon: Icon(Icons.video_call),
                  ),
                ),
                ListTile(
                  title: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setStateDialog(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  title:
                      Text("${selectedTime.hour}:${selectedTime.minute}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked =
                        await showTimePicker(context: context, initialTime: selectedTime);
                    if (picked != null) {
                      setStateDialog(() => selectedTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              await createAppointment(dateTime);
              Navigator.pop(context);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes rendez-vous'),
        bottom: TabBar(
          controller: _tabController,
          tabs: statuses.map((s) => Tab(text: statusLabel(s))).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: statuses.map(buildAppointmentList).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateAppointmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
