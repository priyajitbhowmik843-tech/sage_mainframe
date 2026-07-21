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

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
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
                    title: 'SELECT PERSONA',
                    child: Consumer<AppState>(
                      builder: (context, state, child) {
                        final allPersonas = [
                          ...AppState.personas,
                          ...state.employees.map((e) => Persona(
                                id: e.id,
                                name: e.name,
                                role: PersonaRole.employee,
                                initials: e.name.isNotEmpty ? e.name[0].toUpperCase() : 'E',
                                password: e.password,
                              )),
                        ];

                        if (allPersonas.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: SageColors.yellowAccent),
                            ),
                          );
                        }

                        return Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: allPersonas.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final p = allPersonas[index];
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SageColors.surface,
                                  foregroundColor: SageColors.onSurface,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: SageColors.outline),
                                  ),
                                ),
                                onPressed: () async {
                                  await context.read<AppState>().login(p);
                                },
                                child: Text('${p.name} - ${p.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                        );
                      },
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







