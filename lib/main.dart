import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'widgets/common_widgets.dart';
import 'screens/ceo_dashboard.dart';
import 'screens/cofounder_dashboard.dart';
import 'screens/employee_dashboard.dart';
import 'screens/videographer_dashboard.dart';
import 'screens/dual_role_dashboard.dart';
import 'screens/graphics_editor_dashboard.dart';
import 'screens/marketing_executive_dashboard.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _setupNotificationChannels();
  print("Handling a background message: ${message.messageId}");
  await _showLocalNotificationFromData(message);
}

Future<void> _showLocalNotificationFromData(RemoteMessage message) async { }

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _setupNotificationChannels() async { }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _setupNotificationChannels();
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotificationFromData(message);
    });
  }

  final prefs = await SharedPreferences.getInstance();
  final savedId = prefs.getString('active_persona_id');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(initialPersonaId: savedId),
      child: const SageMainframeApp(),
    ),
  );
}

class SageMainframeApp extends StatelessWidget {

  const SageMainframeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Sage',
      theme: SageTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

// ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ LOGIN SCREEN ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¢Ã¢â‚¬ÂÃ¢â€šÂ¬
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _pulse;
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AppState>().isLoggedIn;
    if (isLoggedIn) {
      return const MainShell();
    }

    return Scaffold(
      backgroundColor: SageColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset('assets/logo/sage_logo.png', fit: BoxFit.contain, width: 300),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (ctx, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulse.value * 0.05),
                          child: child,
                        );
                      },
                      child: Image.asset('assets/logo/sage_logo.png', height: 160),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Sage',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: SageColors.onBackground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TerminalPanel(
                    title: 'SECURE SYSTEM LOGIN',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ENTER CREDENTIALS:',
                          style: TextStyle(color: SageColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _idCtrl,
                          style: const TextStyle(color: SageColors.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Employee ID',
                            labelStyle: const TextStyle(color: SageColors.onSurfaceVariant),
                            filled: true,
                            fillColor: SageColors.surface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: SageColors.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: SageColors.onSurfaceVariant),
                            filled: true,
                            fillColor: SageColors.surface,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_error != null) ...[
                          Text(_error!, style: const TextStyle(color: SageColors.error, fontSize: 12)),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SageColors.yellowAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.black, width: 1.5),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _doLogin,
                            child: const Text('AUTHORIZE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _doLogin() async {
    setState(() => _error = null);
    final p = context.read<AppState>().authenticate(_idCtrl.text, _passCtrl.text);
    if (p == null) {
      setState(() => _error = 'Invalid credentials or missing password.');
    } else {
      await context.read<AppState>().login(p);
    }
  }
}

// ---------------- MAIN SHELL ----------------
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final persona = context.watch<AppState>().activePersona;

    return Scaffold(
      backgroundColor: SageColors.background,
      body: _buildDashboard(context, persona),
    );
  }

  Widget _buildDashboard(BuildContext context, Persona persona) {
    switch (persona.role) {
      case PersonaRole.ceo: return const CeoDashboard();
      case PersonaRole.cofounder: return const CofounderDashboard();
      case PersonaRole.employee:
        final empInState = context.watch<AppState>().employees.where((e) => e.id == persona.id).firstOrNull;
        if (empInState != null) {
          final roles = empInState.role.split(',').map((r) => r.trim()).where((r) => r.isNotEmpty && r != 'None').toList();
          if (roles.length > 1) {
            // Multi-role employee -> use the smart DualRoleDashboard
            return DualRoleDashboard(roles: roles);
          } else if (empInState.hasRole('videographer') || empInState.hasRole('videographer/cinematographer')) {
            return const VideographerDashboard();
          } else if (empInState.hasRole('marketing executive') || empInState.hasRole('marketing')) {
            return const MarketingExecutiveDashboard();
          } else if (empInState.hasRole('graphics editor') || empInState.hasRole('graphics')) {
            return const GraphicsEditorDashboard();
          }
        }
        return const EmployeeDashboard();
    }
  }
}







