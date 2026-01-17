import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'backend_routes.dart';
import 'dashboard_page.dart';
import 'services/auth_storage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool loading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  Future<void> _register() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom est requis")),
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'email est requis")),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le mot de passe doit contenir au moins 6 caractères")),
      );
      return;
    }

    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse("${BackendRoutes.baseUrl}${BackendRoutes.register}");

      debugPrint("Tentative d'inscription vers: $url");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "password_confirmation": confirmController.text,
        }),
      );

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Response: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        String msg = "Erreur";
        try {
          final parsed = jsonDecode(response.body);
          msg = parsed["message"] ?? parsed["error"]?.toString() ?? msg;
        } catch (_) {
          msg = "Erreur: réponse inattendue du backend";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        setState(() => loading = false);
        return;
      }

      final data = jsonDecode(response.body);
      final token = data["access_token"] ?? data["token"];
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token introuvable")),
        );
        setState(() => loading = false);
        return;
      }

      await AuthStorage.saveToken(token);
      await AuthStorage.saveUser(data["user"]["name"], data["user"]["email"]);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            userName: data["user"]["name"],
            userEmail: data["user"]["email"],
          ),
        ),
      );
    } catch (e) {
      debugPrint("Erreur register: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur register: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Contenu scrollable
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 80,
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Créer un compte",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Rejoignez-nous aujourd'hui",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Formulaire
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Nom
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: nameController,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: "Nom complet",
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                prefixIcon: Icon(Icons.person_outline, color: Color(0xFF6B7280)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Email
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF6B7280)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: "Mot de passe",
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Confirm Password
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: confirmController,
                              obscureText: true,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: "Confirmer le mot de passe",
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Bouton S'inscrire
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: const Color(0xFF4F46E5).withOpacity(0.6),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "S'inscrire",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 100), // Espace pour le footer
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer fixé en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Déjà un compte ? ",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(
                          color: Color(0xFF4F46E5),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}