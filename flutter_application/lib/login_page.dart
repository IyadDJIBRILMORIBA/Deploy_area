import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'backend_routes.dart';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'services/auth_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ["email", "profile"],
  );

  Future<void> _onGoogleLogin() async {
    setState(() => loading = true);

    try {
      // Déconnecter d'abord pour forcer la sélection de compte
      await _googleSignIn.signOut();
      
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() => loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      
      if (idToken == null) {
        debugPrint("Google returned no idToken");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur: Pas de token Google")),
        );
        setState(() => loading = false);
        return;
      }

      debugPrint("Google ID Token récupéré: ${idToken.substring(0, 20)}...");
      if (accessToken != null) {
        debugPrint("Google Access Token récupéré: ${accessToken.substring(0, 20)}...");
      }

      final url = Uri.parse("${BackendRoutes.baseUrl}${BackendRoutes.googleAuth}");
      
      debugPrint("Envoi vers: $url");
      
      // Envoyer l'idToken ET l'accessToken (si disponible)
      final body = {
        "token": idToken,
        if (accessToken != null) "access_token": accessToken,
      };
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("Backend status: ${response.statusCode}");
      debugPrint("Backend response: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        String msg;
        try {
          final parsed = jsonDecode(response.body);
          msg = parsed["message"] ?? parsed["error"]?.toString() ?? "Erreur authentification";
        } catch (_) {
          msg = "Erreur serveur: ${response.statusCode}";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        setState(() => loading = false);
        return;
      }

      final data = jsonDecode(response.body);
      final token = data["token"] ?? data["access_token"];

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"]?.toString() ?? "Token introuvable")),
        );
        setState(() => loading = false);
        return;
      }

      if (data["user"] == null || data["user"]["name"] == null || data["user"]["email"] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Données utilisateur manquantes")),
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
    } catch (e, st) {
      debugPrint("Erreur Google Login: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Google login: $e")),
      );
    }

    setState(() => loading = false);
  }

  Future<void> _onEmailLogin() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse("${BackendRoutes.baseUrl}${BackendRoutes.login}");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      if (response.statusCode != 200) {
        String msg;
        try {
          final parsed = jsonDecode(response.body);
          msg = parsed["message"] ?? parsed["error"]?.toString() ?? "Erreur";
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
      debugPrint("Erreur login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur login: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
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
                    // Header avec logo
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                      child: Column(
                        children: [
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
                          Text(
                            "Bon retour ! 👋",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Connectez-vous pour continuer",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
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
                          // Email
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                            ),
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.grey.shade600 : const Color(0xFF9CA3AF),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: isDark ? Colors.grey.shade500 : const Color(0xFF6B7280),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                            ),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "Mot de passe",
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.grey.shade600 : const Color(0xFF9CA3AF),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: isDark ? Colors.grey.shade500 : const Color(0xFF6B7280),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Bouton Connexion
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: loading ? null : _onEmailLogin,
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
                                      "Se connecter",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "OU",
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade600 : const Color(0xFF9CA3AF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Bouton Google amélioré
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: loading ? null : _onGoogleLogin,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                              Center(
                                                child: ShaderMask(
                                                  shaderCallback: (bounds) => const LinearGradient(
                                                    colors: [
                                                      Color(0xFF4285F4),
                                                      Color(0xFFEA4335),
                                                    ],
                                                  ).createShader(bounds),
                                                  child: const Text(
                                                    'G',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Continuer avec Google",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pas de compte ? ",
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade500 : const Color(0xFF6B7280),
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text(
                        "S'inscrire",
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