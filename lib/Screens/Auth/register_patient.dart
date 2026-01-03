import 'package:emart_app/Screens/Auth/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class RegisterPatient extends StatefulWidget {
  const RegisterPatient({super.key});

  @override
  State<RegisterPatient> createState() => _RegisterPatientState();
}

class _RegisterPatientState extends State<RegisterPatient> {
  final _formKey = GlobalKey<FormState>();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  bool loading = false;

  Future<void> registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => loading = true);

      // 1️⃣ Création du compte Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // 2️⃣ Enregistrement dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstNameCtrl.text.trim(),
        'lastName': lastNameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'dateOfBirth': dobCtrl.text.trim(),
        'role': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3️⃣ Déconnexion obligatoire après signup
      await FirebaseAuth.instance.signOut();

      // 4️⃣ Message + redirection vers Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte créé avec succès. Connectez-vous."),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF03BE96)),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un compte patient"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameCtrl,
                decoration: inputStyle("Prénom", Icons.person),
                validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: lastNameCtrl,
                decoration: inputStyle("Nom", Icons.person_outline),
                validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: emailCtrl,
                decoration: inputStyle("Email", Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.contains('@') ? null : "Email invalide",
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: passwordCtrl,
                decoration: inputStyle("Mot de passe", Icons.lock),
                obscureText: true,
                validator: (v) =>
                    v!.length < 6 ? "Minimum 6 caractères" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: phoneCtrl,
                decoration: inputStyle("Téléphone", Icons.phone),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: addressCtrl,
                decoration: inputStyle("Adresse", Icons.location_on),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: dobCtrl,
                decoration: inputStyle(
                    "Date de naissance (JJ/MM/AAAA)", Icons.cake),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: 90.w,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: loading ? null : registerPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03BE96),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Créer le compte",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
