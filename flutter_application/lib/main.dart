import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_storage.dart';
import 'services/deep_link_handler.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser le gestionnaire de deep links
  await DeepLinkHandler.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget currentPage = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthStorage.getToken();
    final name = await AuthStorage.getUserName();
    final email = await AuthStorage.getUserEmail();

    if (token != null && name != null && email != null) {
      setState(() => currentPage = DashboardPage(userName: name, userEmail: email));
    } else {
      setState(() => currentPage = const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: "Area",
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/dashboard": (context) => const DashboardPage(),
      },
      home: currentPage,
    );
  }
}
