import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/audio_service.dart';
import '../services/fcm_service.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class PoolData {
  final double income;
  final double expenses;
  final double netBalance;
  final Map<String, double> shares;

  PoolData({required this.income, required this.expenses, required this.shares})
    : netBalance = income - expenses;
}

class AppState extends ChangeNotifier {
  final String? initialPersonaId;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  StreamSubscription? _tasksSub;
  StreamSubscription? _employeesSub;
  StreamSubscription? _clientsSub;
  StreamSubscription? _financesSub;
  StreamSubscription? _notificationsSub;
  StreamSubscription? _incomeSub;
  StreamSubscription? _executivesSub;
  String? firestoreError;

  bool _isInitialNotificationLoad = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, double> _monthlyIncome = {};
  Map<String, double> get monthlyIncome => _monthlyIncome;

  Map<String, double> _netRunningBalance = {};
  Map<String, double> get netRunningBalance => _netRunningBalance;

  Map<String, int> _monthlyActiveClients = {};
  Map<String, int> get monthlyActiveClients => _monthlyActiveClients;

  final _db = FirebaseFirestore.instance;

  bool _autoEmployeesGenerated = false;

  AppState({this.initialPersonaId}) {
    if (initialPersonaId != null) {
      final p = personas.where((p) => p.id == initialPersonaId).firstOrNull;
      if (p != null) {
        _activePersona = p;
        _isLoggedIn = true;
      }
    }
    _runEmployeeMigrations();

    // --- Tasks stream ---
    _tasksSub = _db
        .collection('tasks')
        .snapshots()
        .listen(
          (snapshot) {
            firestoreError = null;
            _tasks.clear();
            for (var doc in snapshot.docs) {
              try {
                _tasks.add(Task.fromFirestore(doc.data(), doc.id));
              } catch (e) {
                firestoreError = "Parse error: $e";
              }
            }
            notifyListeners();
          },
          onError: (e) {
            firestoreError = e.toString();
            notifyListeners();
          },
        );

    // --- Employees stream ---
    _employeesSub = _db.collection('employees').snapshots().listen((snapshot) {
      _employees.clear();
      for (var doc in snapshot.docs) {
        try {
          final emp = Employee.fromFirestore(doc.data(), doc.id);
          _employees.add(emp);
          if (initialPersonaId != null &&
              !_isLoggedIn &&
              emp.id == initialPersonaId) {
            _activePersona = Persona(
              id: emp.id,
              name: emp.name,
              role: PersonaRole.employee,
              initials: emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
              password: emp.password,
              phone: emp.phone,
              email: emp.email,
              address: emp.address,
            );
            _isLoggedIn = true;
          }
        } catch (_) {}
      }

      // Auto-generate missing essential team members
      if (!_autoEmployeesGenerated) {
        _autoEmployeesGenerated = true;
        if (_employees
            .where((e) => e.name.toLowerCase().contains('debjit'))
            .isEmpty) {
          addEmployee(
            name: 'Debjit',
            role: 'Video Editor',
            department: 'Production',
          );
        }
        if (_employees
            .where((e) => e.name.toLowerCase().contains('poulom'))
            .isEmpty) {
          addEmployee(
            name: 'Poulom',
            role: 'Videographer',
            department: 'Production',
          );
        }
        if (_employees
            .where((e) => e.name.toLowerCase().contains('sourav'))
            .isEmpty) {
          addEmployee(
            name: 'Sourav',
            role: 'Marketing Executive',
            department: 'Marketing',
          );
        }
      }

      notifyListeners();
    }, onError: (_) {});

    // --- Clients stream ---
    _clientsSub = _db.collection('clients').snapshots().listen((snapshot) {
      _clients.clear();
      for (var doc in snapshot.docs) {
        try {
          final client = Client.fromFirestore(doc.data(), doc.id);
          _clients.add(client);
        } catch (_) {}
      }

      notifyListeners();
    }, onError: (_) {});

    // --- Finances stream ---
    _financesSub = _db.collection('finances').snapshots().listen((snapshot) {
      _finances.clear();
      for (var doc in snapshot.docs) {
        try {
          _finances.add(FinanceEntry.fromFirestore(doc.data(), doc.id));
        } catch (e, stack) {
          print("Error parsing finance ${doc.id}: $e");
          print(stack);
        }
      }
      _finances.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    }, onError: (_) {});

    // --- Notifications stream ---
    _notificationsSub = _db
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen(
          (snapshot) {
            if (!_isInitialNotificationLoad) {
              for (var change in snapshot.docChanges) {
                if (change.type == DocumentChangeType.added) {
                  try {
                    final notif = SageNotification.fromFirestore(
                      change.doc.data()!,
                      change.doc.id,
                    );
                    _playNotificationSound(notif);
                  } catch (_) {}
                }
              }
            }

            _isInitialNotificationLoad = false;

            _notifications.clear();
            for (var doc in snapshot.docs) {
              try {
                _notifications.add(
                  SageNotification.fromFirestore(doc.data(), doc.id),
                );
              } catch (_) {}
            }
            notifyListeners();
          },
          onError: (e) {
            print('NOTIFICATIONS STREAM ERROR: $e');
          },
        );

    // --- Executives stream ---
    _executivesSub = _db.collection('executive_profiles').snapshots().listen((
      snapshot,
    ) {
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final index = personas.indexWhere((element) => element.id == doc.id);
          if (index != -1) {
            personas[index].phone = data['phone'] ?? '';
            personas[index].email = data['email'] ?? '';
            personas[index].address = data['address'] ?? '';
            personas[index].dob = data['dob'] ?? '';
            personas[index].gender = data['gender'] ?? '';
            personas[index].preferredName = data['preferredName'] ?? '';
            personas[index].emergencyContact = data['emergencyContact'] ?? '';
            personas[index].professionalBio = data['professionalBio'] ?? '';
            personas[index].workLocation = data['workLocation'] ?? '';
            personas[index].workStylePreference =
                data['workStylePreference'] ?? '';
            personas[index].interests = data['interests'] ?? '';
            personas[index].keySkills =
                (data['keySkills'] as List<dynamic>? ?? [])
                    .map((e) => e.toString())
                    .toList();
            personas[index].strengths =
                (data['strengths'] as List<dynamic>? ?? [])
                    .map((e) => e.toString())
                    .toList();
            personas[index].avatar = data['avatar'] ?? 0;

            if (_activePersona?.id == doc.id) {
              _activePersona = personas[index];
            }
          }
        } catch (_) {}
      }
      notifyListeners();
    }, onError: (_) {});

    // --- Income stream ---
    _incomeSub = _db.collection('settings').doc('finance').snapshots().listen((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        _monthlyIncome = (data['monthlyIncome'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, (value as num).toDouble()));
        _netRunningBalance =
            (data['netRunningBalance'] as Map<String, dynamic>? ?? {}).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            );
        _monthlyActiveClients =
            (data['monthlyActiveClients'] as Map<String, dynamic>? ?? {}).map(
              (key, value) => MapEntry(key, (value as num).toInt()),
            );
      } else {
        _monthlyIncome = {};
        _netRunningBalance = {};
        _monthlyActiveClients = {};
      }
      notifyListeners();
    }, onError: (_) {});
  }

  Future<void> _runEmployeeMigrations() async {
    try {
      final snapshot = await _db.collection('employees').get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = (data['name'] as String?)?.toLowerCase() ?? '';

        if (!data.containsKey('sessionRestoreFixed')) {
          if (name.contains('soumyabrata')) {
            await doc.reference.update({
              'sessionRestoreFixed': true,
              'pendingPayMonth': 'Session',
              'pendingPayAmount': 1200.0,
              'paymentCleared': true,
              'paymentApprovedByEmployee': false,
            });
            _addLog('MIGRATION: Restored Soumyabrata session payment');
          } else {
            await doc.reference.update({'sessionRestoreFixed': true});
          }
        }

        if (!data.containsKey('joiningDateFixed')) {
          try {
            final Timestamp? joinedTs = data['joiningDate'] as Timestamp?;
            if (joinedTs != null) {
              final joinedDate = joinedTs.toDate();
              if (joinedDate.year == 2025 &&
                  joinedDate.month == 5 &&
                  joinedDate.day == 1) {
                // Was defaulted. Update to June 1, 2026 so pending months evaluates to 1 after July 16
                await doc.reference.update({
                  'joiningDate': Timestamp.fromDate(DateTime(2026, 6, 1)),
                  'joiningDateFixed': true,
                });
                _addLog('MIGRATION: Updated default joiningDate for $name');
              } else {
                await doc.reference.update({'joiningDateFixed': true});
              }
            } else {
              // No joining date, set to June 1, 2026
              await doc.reference.update({
                'joiningDate': Timestamp.fromDate(DateTime(2026, 6, 1)),
                'joiningDateFixed': true,
              });
            }
          } catch (_) {
            await doc.reference.update({'joiningDateFixed': true});
          }
        }

        if (!data.containsKey('paymentMode')) {
          if (name.contains('debjit')) {
            await doc.reference.update({
              'paidMonths': ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
              'paymentMode': 'Late',
              'pendingPayMonth': FieldValue.delete(),
              'pendingPayAmount': 0.0,
            });
            _addLog('MIGRATION: Updated Debjit data');
          } else if (name.contains('soumyabrata')) {
            await doc.reference.update({
              'paidMonths': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
              'paymentMode': 'Running',
            });
            _addLog('MIGRATION: Updated Soumyabrata data');
          } else {
            await doc.reference.update({'paymentMode': 'Running'});
          }
        }
      }
    } catch (e) {
      print('Migration error: $e');
    }
  }

  void updateMonthlyIncome(String monthKey, double amount) {
    _db.collection('settings').doc('finance').set({
      'monthlyIncome': {monthKey: amount},
    }, SetOptions(merge: true));
  }

  void updateNetRunningBalance(String monthKey, double amount) {
    _db.collection('settings').doc('finance').set({
      'netRunningBalance': {monthKey: amount},
    }, SetOptions(merge: true));
  }

  void updateMonthlyActiveClients(String monthKey, int clients) {
    _db.collection('settings').doc('finance').set({
      'monthlyActiveClients': {monthKey: clients},
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    _employeesSub?.cancel();
    _clientsSub?.cancel();
    _financesSub?.cancel();
    _notificationsSub?.cancel();
    _incomeSub?.cancel();
    _executivesSub?.cancel();
    super.dispose();
  }

  // --- Active Persona ---
  Persona _activePersona = personas[0]; // Default: Sohini (CEO)
  Persona get activePersona => _activePersona;

  void setPersona(Persona p) {
    _activePersona = p;
    _isLoggedIn = true;
    FcmService.initializeAndSaveToken(p.id);
    notifyListeners();
  }

  Future<void> login(Persona p) async {
    _activePersona = p;
    _isLoggedIn = true;
    FcmService.initializeAndSaveToken(p.id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_persona_id', p.id);
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_persona_id');
  }

  // --- Static Personas ---
  static final List<Persona> personas = [
    Persona(
      id: 'CEO-SOH-001',
      name: 'Sohini',
      role: PersonaRole.ceo,
      initials: 'SD',
      password: 'X12345',
    ),
    Persona(
      id: 'COF-RIT-001',
      name: 'Ritam',
      role: PersonaRole.cofounder,
      initials: 'RD',
      password: 'X12345',
    ),
    Persona(
      id: 'COF-PRI-001',
      name: 'Priyajit',
      role: PersonaRole.cofounder,
      initials: 'PB',
      password: 'X12345',
    ),
  ];

  Persona? authenticate(String id, String password) {
    if (password.trim().isEmpty) return null;

    final lowerId = id.trim().toLowerCase();

    // Check static personas (CEO/Cofounders)
    for (var p in personas) {
      if (p.id.toLowerCase() == lowerId &&
          p.password.trim() == password.trim()) {
        return p;
      }
    }

    // Check employees
    for (var emp in _employees) {
      if (emp.id.toLowerCase() == lowerId &&
          emp.password.trim() == password.trim()) {
        return Persona(
          id: emp.id,
          name: emp.name,
          role: PersonaRole.employee,
          initials: emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
          password: emp.password,
        );
      }
    }

    return null;
  }

  // --- Retired IDs ---
  final Set<String> _retiredIds = {};
  Set<String> get retiredIds => _retiredIds;

  // --- Employees ---
  final List<Employee> _employees = [];

  List<Employee> get employees => List.unmodifiable(_employees);

  Map<String, String>? addEmployee({
    required String name,
    required String role,
    required String department,
    double monthlySalary = 0.0,
    double perSessionRate = 0.0,
    double perVideoRate = 0.0,
    double perSkuRate = 0.0,
    double perDesignRate = 0.0,
    double pendingPayDeduction = 0.0,
    int sessionsPerMonth = 0,
  }) {
    if (name.trim().isEmpty) {
      return {'error': 'Name cannot be empty.'};
    }

    final prefix = name.trim().replaceAll(' ', '').toUpperCase();
    final namePart = prefix.isEmpty
        ? 'EMP'
        : prefix.substring(0, min(3, prefix.length));

    // Find next sequence number for this prefix
    int maxSeq = 0;
    for (var e in _employees) {
      if (e.id.startsWith('EMP-$namePart-')) {
        final parts = e.id.split('-');
        if (parts.length == 3) {
          final seq = int.tryParse(parts[2]) ?? 0;
          if (seq > maxSeq) maxSeq = seq;
        }
      }
    }
    final newId = 'EMP-$namePart-${(maxSeq + 1).toString().padLeft(3, '0')}';

    // Generate random password: 1 upper char + 5 numbers
    final rand = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final p1 = chars[rand.nextInt(chars.length)];
    final p2 = rand.nextInt(100000).toString().padLeft(5, '0');
    final newPassword = '$p1$p2';

    final emp = Employee(
      id: newId,
      name: name,
      role: role,
      department: department,
      password: newPassword,
      monthlySalary: monthlySalary,
      perSessionRate: perSessionRate,
      perVideoRate: perVideoRate,
      perSkuRate: perSkuRate,
      perDesignRate: perDesignRate,
      pendingPayDeduction: pendingPayDeduction,
      sessionsPerMonth: sessionsPerMonth,
      paidMonths: const [],
      sessionsPaid: 0,
      skusPaid: 0,
      address: '',
      phone: '',
      email: '',
      avatar: Random().nextInt(5),
      joiningDate: DateTime.now(),
    );
    // Write to Firestore (stream will update local list)
    _db.collection('employees').doc(newId).set(emp.toFirestore());
    _addLog(
      'EMPLOYEE ADDED: $name ($newId) - ${DateTime.now().toString().substring(0, 16)}',
    );
    _addNotification('New team member added: $name ($role)', 'employee_added');
    return {'id': newId, 'password': newPassword};
  }

  void acknowledgeVideographerPayment(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isPaymentAcknowledgedByVideographer = true;
      _db.collection('tasks').doc(taskId).update({
        'isPaymentAcknowledgedByVideographer': true,
      });
      _addLog(
        'PAYMENT ACKNOWLEDGED: "${_tasks[idx].title}" by Videographer ${_activePersona.name}',
      );
      notifyListeners();
    }
  }

  void approveVideographerSession(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isApprovedByVideographer = true;
      _db.collection('tasks').doc(taskId).update({
        'isApprovedByVideographer': true,
      });
      _addLog(
        'SESSION APPROVED: "${_tasks[idx].title}" by Videographer ${_activePersona.name}',
      );
      notifyListeners();
    }
  }

  void acknowledgeGraphicsEditorPayment(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isPaymentAcknowledgedByGraphicsEditor = true;
      _db.collection('tasks').doc(taskId).update({
        'isPaymentAcknowledgedByGraphicsEditor': true,
      });
      _addLog(
        'PAYMENT ACKNOWLEDGED: "${_tasks[idx].title}" by Graphics Editor ${_activePersona.name}',
      );
      notifyListeners();
    }
  }

  void approveGraphicsEditorSession(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isApprovedByGraphicsEditor = true;
      _db.collection('tasks').doc(taskId).update({
        'isApprovedByGraphicsEditor': true,
      });
      _addLog(
        'SESSION APPROVED: "${_tasks[idx].title}" by Graphics Editor ${_activePersona.name}',
      );
      notifyListeners();
    }
  }

  void updateEmployee(
    String id, {
    String? name,
    String? role,
    String? department,
    String? password,
    double? monthlySalary,
    double? perSessionRate,
    double? perVideoRate,
    double? perSkuRate,
    double? perDesignRate,
    double? pendingPayDeduction,
    int? sessionsPerMonth,
    int? paymentsDue,
    DateTime? lastPaidDate,
    String? address,
    String? phone,
    String? email,
    int? avatar,
    String? preferredName,
    String? workLocation,
    String? emergencyContact,
    String? professionalBio,
    List<String>? keySkills,
    List<String>? strengths,
    String? workStylePreference,
    String? interests,
    String? videoEditorPayType,
  }) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final emp = _employees[idx];
    if (name != null) emp.name = name;
    if (role != null) emp.role = role;
    if (department != null) emp.department = department;
    if (password != null) emp.password = password;
    if (monthlySalary != null) emp.monthlySalary = monthlySalary;
    if (perSessionRate != null) emp.perSessionRate = perSessionRate;
    if (perVideoRate != null) emp.perVideoRate = perVideoRate;
    if (perSkuRate != null) emp.perSkuRate = perSkuRate;
    if (perDesignRate != null) emp.perDesignRate = perDesignRate;
    if (pendingPayDeduction != null)
      emp.pendingPayDeduction = pendingPayDeduction;
    if (sessionsPerMonth != null) emp.sessionsPerMonth = sessionsPerMonth;
    if (paymentsDue != null) emp.paymentsDue = paymentsDue;
    if (lastPaidDate != null) emp.lastPaidDate = lastPaidDate;
    if (address != null) emp.address = address;
    if (phone != null) emp.phone = phone;
    if (email != null) emp.email = email;
    if (avatar != null) emp.avatar = avatar;
    if (preferredName != null) emp.preferredName = preferredName;
    if (workLocation != null) emp.workLocation = workLocation;
    if (emergencyContact != null) emp.emergencyContact = emergencyContact;
    if (professionalBio != null) emp.professionalBio = professionalBio;
    if (keySkills != null) emp.keySkills = keySkills;
    if (strengths != null) emp.strengths = strengths;
    if (workStylePreference != null)
      emp.workStylePreference = workStylePreference;
    if (interests != null) emp.interests = interests;

    if (preferredName != null) emp.preferredName = preferredName;
    if (workLocation != null) emp.workLocation = workLocation;
    if (emergencyContact != null) emp.emergencyContact = emergencyContact;
    if (professionalBio != null) emp.professionalBio = professionalBio;
    if (keySkills != null) emp.keySkills = keySkills;
    if (strengths != null) emp.strengths = strengths;
    if (workStylePreference != null)
      emp.workStylePreference = workStylePreference;
    if (interests != null) emp.interests = interests;
    if (videoEditorPayType != null) emp.videoEditorPayType = videoEditorPayType;

    _db
        .collection('employees')
        .doc(id)
        .set(emp.toFirestore(), SetOptions(merge: true));
    _addLog('EMPLOYEE UPDATED: ${emp.name} by ${_activePersona.name}');
    _addNotification('Employee updated: ${emp.name}', 'employee_updated');
    notifyListeners();
  }

  void updateEmployeeCompensation(
    String id, {
    double? monthlySalary,
    double? perSessionRate,
    double? perVideoRate,
    double? perDesignRate,
    int? sessionsPerMonth,
  }) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      if (monthlySalary != null) _employees[idx].monthlySalary = monthlySalary;
      if (perSessionRate != null)
        _employees[idx].perSessionRate = perSessionRate;
      if (perVideoRate != null) _employees[idx].perVideoRate = perVideoRate;
      if (perDesignRate != null) _employees[idx].perDesignRate = perDesignRate;
      if (sessionsPerMonth != null)
        _employees[idx].sessionsPerMonth = sessionsPerMonth;
      _db
          .collection('employees')
          .doc(id)
          .set(_employees[idx].toFirestore(), SetOptions(merge: true));
      _addLog('EMPLOYEE COMP SET: ${_employees[idx].name} ($id) updated');
      notifyListeners();
    }
  }

  void toggleEmployeePaidMonth(String id, String monthCode) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final list = List<String>.from(_employees[idx].paidMonths);
      if (list.contains(monthCode)) {
        list.remove(monthCode);
      } else {
        list.add(monthCode);
      }
      _employees[idx].paidMonths = list;
      _db.collection('employees').doc(id).update({'paidMonths': list});
      _addLog('EMPLOYEE MONTH TOGGLED: ${_employees[idx].name} ($monthCode)');
      notifyListeners();
    }
  }

  void updateEmployeeSessionsPaid(String id, int sessionsPaid) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _employees[idx].sessionsPaid = sessionsPaid;
      _db.collection('employees').doc(id).update({
        'sessionsPaid': sessionsPaid,
      });
      _addLog(
        'EMPLOYEE SESSIONS PAID SET: ${_employees[idx].name} ($sessionsPaid)',
      );
      notifyListeners();
    }
  }

  void toggleEmployeePaymentCleared(String id, bool value) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _employees[idx].paymentCleared = value;
      _db.collection('employees').doc(id).update({'paymentCleared': value});
      notifyListeners();
    }
  }

  void payEmployeeSalary(
    String employeeId,
    List<String> months,
    double amount,
  ) {
    final idx = _employees.indexWhere((e) => e.id == employeeId);
    if (idx != -1) {
      final emp = _employees[idx];
      emp.paidMonths = List<String>.from(emp.paidMonths);
      for (final m in months) {
        if (!emp.paidMonths.contains(m)) emp.paidMonths.add(m);
      }
      emp.paymentCleared = true;
      emp.paymentApprovedByEmployee = false;
      emp.pendingPayAmount = amount;
      emp.pendingPayMonth = months.join(", ");

      if (emp.paymentsDue >= months.length) {
        emp.paymentsDue -= months.length;
      } else {
        emp.paymentsDue = 0;
      }
      _db.collection('employees').doc(employeeId).update({
        'paidMonths': emp.paidMonths,
        'paymentCleared': true,
        'paymentApprovedByEmployee': false,
        'pendingPayAmount': amount,
        'pendingPayMonth': emp.pendingPayMonth,
        'paymentsDue': emp.paymentsDue,
      });

      _addLog(
        'SALARY CLEARED FOR APPROVAL: ${emp.name} for ${months.join(", ")} by ${_activePersona.name}',
      );
      notifyListeners();
    }
  }

  void payVideographerSessions(
    String videographerId,
    int sessionCount,
    bool isForSessions,
  ) {
    final emp = _employees.where((e) => e.id == videographerId).firstOrNull;
    if (emp == null) return;

    // Find all unpaid completed tasks matching the exact type requested
    final unpaidSessions = _tasks
        .where(
          (t) =>
              t.assignedTo == videographerId &&
              (isForSessions
                  ? t.taskType == 'Session'
                  : t.taskType != 'Session') &&
              (t.isCompleted ||
                  (isForSessions && t.isApprovedByVideographer)) &&
              !t.isPaidToVideographer,
        )
        .toList();

    // Sort by deadline to pay oldest first
    unpaidSessions.sort((a, b) => a.deadline.compareTo(b.deadline));

    int sessionsToPay = sessionCount;
    if (sessionsToPay > unpaidSessions.length)
      sessionsToPay = unpaidSessions.length;

    double totalPayout = 0;

    for (int i = 0; i < sessionsToPay; i++) {
      final t = unpaidSessions[i];
      t.isPaidToVideographer = true;
      _db.collection('tasks').doc(t.id).update({'isPaidToVideographer': true});

      if (t.taskType == 'Session') {
        final c = _clients
            .where((client) => client.id == t.clientId)
            .firstOrNull;
        if (c != null) {
          totalPayout += c.sessionRate;
        }
      } else {
        totalPayout += emp.perVideoRate;
      }
    }

    if (totalPayout > 0) {
      emp.paymentCleared = true;
      emp.paymentApprovedByEmployee = false;
      emp.pendingPayAmount = totalPayout;
      emp.pendingPayMonth =
          '$sessionsToPay ${!isForSessions ? "Videos" : "Sessions"}';

      _db.collection('employees').doc(videographerId).update({
        'paymentCleared': true,
        'paymentApprovedByEmployee': false,
        'pendingPayAmount': emp.pendingPayAmount,
        'pendingPayMonth': emp.pendingPayMonth,
      });
    }

    _addLog(
      '${!isForSessions ? "VIDEOS" : "SESSIONS"} CLEARED FOR APPROVAL: $sessionsToPay items to ${emp.name} by ${_activePersona.name}',
    );
    notifyListeners();
  }

  void payGraphicsEditorDesigns(
    String employeeId,
    int count,
    double totalPayout,
  ) {
    final emp = _employees.where((e) => e.id == employeeId).firstOrNull;
    if (emp == null) return;

    final unpaidDesigns = _tasks
        .where(
          (t) =>
              t.assignedTo == employeeId &&
              (t.isCompleted || t.isApprovedByGraphicsEditor) &&
              !t.isPaidToGraphicsEditor,
        )
        .toList();

    unpaidDesigns.sort((a, b) => a.deadline.compareTo(b.deadline));

    int toPay = count > unpaidDesigns.length ? unpaidDesigns.length : count;
    for (int i = 0; i < toPay; i++) {
      final t = unpaidDesigns[i];
      t.isPaidToGraphicsEditor = true;
      _db.collection('tasks').doc(t.id).update({
        'isPaidToGraphicsEditor': true,
      });
    }

    if (totalPayout > 0) {
      emp.paymentCleared = true;
      emp.paymentApprovedByEmployee = false;
      emp.pendingPayAmount = totalPayout;
      emp.pendingPayMonth = '$toPay Designs';

      _db.collection('employees').doc(employeeId).update({
        'paymentCleared': true,
        'paymentApprovedByEmployee': false,
        'pendingPayAmount': totalPayout,
        'pendingPayMonth': emp.pendingPayMonth,
      });
    }
  }

  void payEcomExecutiveSkus(
    String employeeId,
    int skuCount,
    double totalPayout,
  ) {
    final emp = _employees.where((e) => e.id == employeeId).firstOrNull;
    if (emp == null) return;

    emp.skusPaid += skuCount;
    emp.paymentCleared = true;
    emp.paymentApprovedByEmployee = false;
    emp.pendingPayAmount = totalPayout;
    emp.pendingPayMonth = '$skuCount SKUs';

    _db.collection('employees').doc(employeeId).update({
      'skusPaid': emp.skusPaid,
      'paymentCleared': true,
      'paymentApprovedByEmployee': false,
      'pendingPayAmount': totalPayout,
      'pendingPayMonth': emp.pendingPayMonth,
    });

    _addLog(
      'SKUS CLEARED FOR APPROVAL: $skuCount SKUs to ${emp.name} by ${_activePersona.name}',
    );
    notifyListeners();
  }

  void toggleEmployeePaymentApproved(String id, bool value) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      if (value) {
        final e = _employees[idx];
        e.paymentApprovedByEmployee = true;
        e.paymentCleared = false;

        final monthStr = e.pendingPayMonth ?? 'Unknown';
        int monthsPaid = 1;
        if (monthStr != 'Unknown' &&
            !monthStr.contains('Videos') &&
            !monthStr.contains('Sessions') &&
            !monthStr.contains('SKUs')) {
          monthsPaid = monthStr.split(',').length;
        }

        if (e.paymentsDue >= monthsPaid) {
          e.paymentsDue -= monthsPaid;
        } else {
          e.paymentsDue = 0;
        }
        final currentPaid = e.lastPaidDate;
        e.lastPaidDate = DateTime(
          currentPaid.year,
          currentPaid.month + 1,
          currentPaid.day,
        );

        final amt = e.pendingPayAmount > 0
            ? e.pendingPayAmount
            : (e.monthlySalary > 0
                  ? e.monthlySalary
                  : (e.perSessionRate * e.sessionsPerMonth));

        e.pendingPayAmount = 0.0;
        e.pendingPayMonth = null;

        _db.collection('employees').doc(id).update({
          'paymentApprovedByEmployee': true,
          'paymentCleared': false,
          'paymentsDue': e.paymentsDue,
          'lastPaidDate': Timestamp.fromDate(e.lastPaidDate),
          'pendingPayAmount': 0.0,
          'pendingPayMonth': FieldValue.delete(),
        });

        // Record the salary expense in the ledger when the payment is finalized
        addFinance(
          FinanceEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: 'Payment - ${e.name} ($monthStr)',
            amount: amt,
            isIncome: false,
            date: DateTime.now(),
            category: monthStr.contains('Misc:')
                ? 'MISC SESSIONS PAYMENT'
                : (monthStr.contains('Sessions') || monthStr.contains('Videos'))
                ? 'SESSIONS PAYMENT'
                : 'Employee Salary',
            expenseType:
                (monthStr.contains('Misc:') ||
                    monthStr.contains('Sessions') ||
                    monthStr.contains('Videos'))
                ? 'Session Payment'
                : 'Salary',
            employeeId: e.id,
            serviceType:
                (e.role == 'Videographer' && monthStr.contains('Misc:'))
                ? 'Video Production'
                : null,
          ),
        );
      } else {
        _employees[idx].paymentApprovedByEmployee = false;
        _db.collection('employees').doc(id).update({
          'paymentApprovedByEmployee': false,
        });
      }
      notifyListeners();
    }
  }

  void payMiscVideographerSession(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final t = _tasks[idx];
      t.isPaidToVideographer = true;
      _db.collection('tasks').doc(taskId).update({
        'isPaidToVideographer': true,
      });

      final empIdx = _employees.indexWhere((e) => e.id == t.assignedTo);
      if (empIdx != -1) {
        final emp = _employees[empIdx];
        final amount = t.manualPaymentAmount ?? 0;
        emp.pendingPayAmount = (emp.pendingPayAmount ?? 0) + amount;

        final newStr = 'Misc: ${t.title}';
        if (emp.pendingPayMonth == null || emp.pendingPayMonth!.isEmpty) {
          emp.pendingPayMonth = newStr;
        } else {
          emp.pendingPayMonth = '${emp.pendingPayMonth}, $newStr';
        }

        emp.paymentCleared = true;
        emp.paymentApprovedByEmployee = false;

        _db.collection('employees').doc(emp.id).update({
          'paymentCleared': true,
          'paymentApprovedByEmployee': false,
          'pendingPayAmount': emp.pendingPayAmount,
          'pendingPayMonth': emp.pendingPayMonth,
        });

        _addLog('MISC SESSION PAID: ${emp.name} for ${t.title}');
        _addNotification(
          'Payment cleared for ${emp.name}: ${t.title}',
          'payment',
        );
        notifyListeners();
      }
    }
  }

  void updateClientPaymentsDue(String clientId, int paymentsDue) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      _clients[idx].paymentsDue = paymentsDue;
      _db.collection('clients').doc(clientId).update({
        'paymentsDue': paymentsDue,
      });
      _addLog('CLIENT DUE SET: ${_clients[idx].name} ($paymentsDue due)');
      notifyListeners();
    }
  }

  String? terminateEmployee(String id) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx == -1) return 'ERROR: Employee not found.';
    final emp = _employees[idx];
    // Delete from Firestore
    _db.collection('employees').doc(id).delete();
    _retiredIds.add(id);
    // Remove their tasks from Firestore
    _db.collection('tasks').where('assignedTo', isEqualTo: id).get().then((
      snap,
    ) {
      for (var doc in snap.docs) {
        doc.reference.delete();
      }
    });
    // Remove their messages (local only)
    _addLog('EMPLOYEE TERMINATED: ${emp.name} ($id) - ID RETIRED PERMANENTLY');
    _addNotification('Employee terminated: ${emp.name}', 'employee_terminated');
    notifyListeners();
    return null;
  }

  // --- Tasks ---
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> tasksForPersona(String personaId) =>
      _tasks.where((t) => t.assignedTo == personaId).toList();

  List<Task> tasksForDate(String personaId, DateTime date) {
    return _tasks.where((t) {
      return t.assignedTo == personaId &&
          t.deadline.year == date.year &&
          t.deadline.month == date.month &&
          t.deadline.day == date.day;
    }).toList();
  }

  List<Task> allTasksForDate(DateTime date) {
    return _tasks.where((t) {
      return t.deadline.year == date.year &&
          t.deadline.month == date.month &&
          t.deadline.day == date.day;
    }).toList();
  }

  Future<String?> assignTask({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime deadline,
    String? clientId,
    String? taskType,
    String? instructions,
    List<String> sessionClientIds = const [],
    bool isApprovedByVideographer = false,
    double? manualPaymentAmount,
  }) async {
    if (title.trim().isEmpty) return 'ERROR: Task title is required.';

    final newTask = Task(
      id: '', // Firestore generates this
      title: title,
      description: description,
      assignedTo: assignedTo,
      assignedBy: _activePersona.id,
      deadline: deadline,
      clientId: clientId,
      taskType: taskType,
      instructions: instructions,
      sessionClientIds: sessionClientIds,
      isApprovedByVideographer: isApprovedByVideographer,
      manualPaymentAmount: manualPaymentAmount,
    );
    try {
      await _db.collection('tasks').add(newTask.toFirestore());
      _addLog(
        'TASK ASSIGNED: "$title" --- $assignedTo (due ${deadline.toString().substring(0, 10)})',
      );
      _addNotification(
        'Task assigned: "$title" --- $assignedTo (due ${deadline.toString().substring(0, 10)})',
        'task_assigned',
      );

      // Trigger Push Notification via FCM Service
      FcmService.sendNotification(
        targetPersonaId: assignedTo,
        title: 'New Task: $title',
        body: 'You have been assigned a new task by ${_activePersona.name}.',
      );

      return null;
    } catch (e) {
      return "FIRESTORE WRITE ERROR: $e";
    }
  }

  void toggleTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final newVal = !_tasks[idx].isCompleted;
      _tasks[idx].isCompleted = newVal;
      _db.collection('tasks').doc(taskId).update({'isCompleted': newVal});
      notifyListeners();
    }
  }

  void requestPostponeTask(String taskId, DateTime newDate) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _db.collection('tasks').doc(taskId).update({
        'isPostponeRequested': true,
        'postponeRequestedDate': Timestamp.fromDate(newDate),
      });
      _addLog(
        'POSTPONE REQUESTED: "${_tasks[idx].title}" to ${newDate.toString().substring(0, 10)}',
      );
      _addNotification(
        'Task Postpone Requested: "${_tasks[idx].title}"',
        'task',
      );
    }
  }

  void approvePostponeTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final requestedDate = task.postponeRequestedDate;
      if (requestedDate != null) {
        final siblingTasks = _tasks
            .where(
              (t) =>
                  t.title == task.title &&
                  t.deadline.isAtSameMomentAs(task.deadline) &&
                  !t.isCompleted,
            )
            .toList();

        for (final st in siblingTasks) {
          _db.collection('tasks').doc(st.id).update({
            'deadline': Timestamp.fromDate(requestedDate),
            'isPostponeRequested': false,
            'postponeRequestedDate': null,
          });
        }
        _addLog(
          'POSTPONE APPROVED: "${task.title}" moved to ${requestedDate.toString().substring(0, 10)}',
        );
        _addNotification('Task Postpone Approved: "${task.title}"', 'task');
      }
    }
  }

  void rejectPostponeTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _db.collection('tasks').doc(taskId).update({
        'isPostponeRequested': false,
        'postponeRequestedDate': null,
      });
      _addLog('POSTPONE REJECTED: "${_tasks[idx].title}"');
      _addNotification(
        'Task Postpone Rejected: "${_tasks[idx].title}"',
        'task',
      );
    }
  }

  final Set<String> _submittingTasks = {};

  Future<void> submitTask(String taskId) async {
    if (_submittingTasks.contains(taskId)) return;
    _submittingTasks.add(taskId);
    try {
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        final task = _tasks[idx];
        final typeStr = (task.taskType ?? '').toLowerCase();

        if ((typeStr == 'daily video' || typeStr == 'daily post') &&
            task.uploadTaskId == null) {
          String clientName = 'Unknown';
          if (task.clientId != null) {
            final cIdx = _clients.indexWhere((c) => c.id == task.clientId);
            if (cIdx != -1) clientName = _clients[cIdx].name;
          }

          if (clientName == 'Unknown' && task.title.contains(' - ')) {
            clientName = task.title.split(' - ').last.trim();
          }

          final typeDisplay = typeStr == 'daily video'
              ? 'Daily Video'
              : 'Daily Post';
          final newUploadTask = Task(
            id: '',
            title: 'Upload $typeDisplay By 7:30 MAX - $clientName',
            description:
                'Upload required before $typeDisplay can be approved. Original task: ${task.title}',
            assignedTo: 'CEO-SOH-001',
            assignedBy: _activePersona.id,
            deadline: DateTime.now(),
            clientId: task.clientId,
            taskType: 'Upload $typeDisplay',
          );

          try {
            final docRef = await _db
                .collection('tasks')
                .add(newUploadTask.toFirestore());
            _db.collection('tasks').doc(taskId).update({
              'isSubmitted': true,
              'submittedAt': Timestamp.now(),
              'uploadTaskId': docRef.id,
            });
            _addNotification(
              'Task Submitted for Review: "${task.title}" (Upload Task Created)',
              'task',
            );
          } catch (e) {
            print('Error creating upload task: $e');
          }
        } else {
          _db.collection('tasks').doc(taskId).update({
            'isSubmitted': true,
            'submittedAt': Timestamp.now(),
          });
          _addNotification(
            'Task Submitted for Review: "${task.title}"',
            'task',
          );
        }
      }
    } finally {
      _submittingTasks.remove(taskId);
    }
  }

  void unsubmitTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final updates = <String, dynamic>{'isSubmitted': false};

      if (task.uploadTaskId != null) {
        _db.collection('tasks').doc(task.uploadTaskId).delete();
        _tasks.removeWhere((t) => t.id == task.uploadTaskId);
        updates['uploadTaskId'] = FieldValue.delete();
      }

      _db.collection('tasks').doc(taskId).update(updates);
    }
  }

  void approveTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      _db.collection('tasks').doc(taskId).update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
      });
      _addNotification('Task Approved: "${task.title}"', 'task');
      _addLog('TASK APPROVED BY CEO: "${task.title}"');
    }
  }

  void rejectTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];

      final updates = <String, dynamic>{
        'isSubmitted': false,
        'rejectedAt': FieldValue.serverTimestamp(),
      };

      if (task.uploadTaskId != null) {
        _db.collection('tasks').doc(task.uploadTaskId).delete();
        _tasks.removeWhere((t) => t.id == task.uploadTaskId);
        updates['uploadTaskId'] = FieldValue.delete();
      }

      _db.collection('tasks').doc(taskId).update(updates);
      _addNotification('Task Rejected: "${task.title}"', 'task');
    }
  }

  void approveAndDeleteTask(String taskId) {
    // Permanently remove from firestore
    _db.collection('tasks').doc(taskId).delete();
    _tasks.removeWhere((t) => t.id == taskId);
    _addLog('TASK APPROVED AND DELETED: $taskId');
    notifyListeners();
  }

  // --- Clients ---
  final List<Client> _clients = [];

  List<Client> get clients => List.unmodifiable(_clients);

  void updateClientResources(
    String clientId, {
    String? resourceLinks,
    String? postRequirements,
  }) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx == -1) return;
    if (resourceLinks != null) {
      _clients[idx].resourceLinks = resourceLinks
          .split('\n')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (postRequirements != null)
      _clients[idx].postRequirements = postRequirements;
    // Sync to Firestore
    _db.collection('clients').doc(clientId).update(_clients[idx].toFirestore());
    _addLog(
      'CLIENT UPDATED: ${_clients[idx].name} - resources/theme modified by ${_activePersona.name}',
    );
    notifyListeners();
  }

  void updateClientStatus(String clientId, String status) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final wasLead = _clients[idx].status == 'Lead';
      _clients[idx].status = status;
      _db.collection('clients').doc(clientId).update({'status': status});
      _addLog('CLIENT STATUS UPDATED: ${_clients[idx].name} -> $status');
      if (wasLead && status == 'Active') {
        _addNotification(
          '--- Lead converted! ${_clients[idx].name} is now an active client!',
          'lead_converted',
        );
      }
      notifyListeners();
    }
  }

  void addClientRemark(String clientId, String remark) {
    if (remark.trim().isEmpty) return;
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      // Prepend remark so newest is first
      _clients[idx].remarks = [
        '[${DateTime.now().toString().substring(0, 10)}] $remark',
        ..._clients[idx].remarks,
      ];
      _db.collection('clients').doc(clientId).update({
        'remarks': _clients[idx].remarks,
      });
      _addLog('CLIENT REMARK ADDED: ${_clients[idx].name}');
      notifyListeners();
    }
  }

  void addEcomSkuLog(String clientId, EcomSkuLog log) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      _clients[idx].ecomSkuLogs.add(log);
      _db.collection('clients').doc(clientId).update({
        'ecomSkuLogs': _clients[idx].ecomSkuLogs
            .map((e) => e.toFirestore())
            .toList(),
      });
      _addLog('ECOM SKU LOG ADDED: ${_clients[idx].name}');
      notifyListeners();
    }
  }

  void addClient(Client client) {
    // Write to Firestore using client.id as document ID
    _db.collection('clients').doc(client.id).set(client.toFirestore());
    _addLog('CLIENT ADDED: ${client.name} by ${_activePersona.name}');
    _addNotification('New client added: ${client.name}', 'client_added');
  }

  void updateClientVideographer(String clientId, String? videographerId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      _clients[idx].assignedVideographerId = videographerId;
      _db.collection('clients').doc(clientId).update({
        'assignedVideographerId': videographerId,
      });
      _addLog(
        'CLIENT VIDEOGRAPHER UPDATED: ${_clients[idx].name} -> ${videographerId ?? "None"} by ${_activePersona.name}',
      );
      notifyListeners();
    }
  }

  void updateClient(
    String clientId, {
    String? name,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? packageType,
    String? contractPeriod,
    double? monthlyPayable,
    String? status,
    String? agreementTerms,
    String? paymentTerms,
    int? paymentsDue,
    int? weeklyReels,
    int? weeklyPosts,
    int? weeklyCarousels,
    int? weeklyStories,
    int? campaigns,
    String? campaignReach,
    String? postRequirements,
    String? contactAddress,
    String? contactWebsite,
    String? conversionProbability,
    String? retentionHealth,
    String? nextDueDate,
    String? paymentMode,
    int? dueDateDay,
    String? assignedVideographerId,
    double? sessionRate,
    String? serviceType,
    bool? hasMarketingCommission,
    String? marketingExecutiveId,
    String? source,
    bool? isApprovedByCeo,
    DateTime? contractDate,
    String? previousStatus,
    String? paidTill,
    String? ecomPaymentType,
    double? clientSkuRate,
    double? clientDuplicateSkuRate,
    double? clientCatalogueRate,
    bool? isWebsiteHandlingActive,
    double? websiteHandlingFee,
  }) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx == -1) return;
    final c = _clients[idx];
    if (name != null) c.name = name;
    if (packageType != null) c.packageType = packageType;
    if (contractPeriod != null) c.contractPeriod = contractPeriod;
    if (monthlyPayable != null) c.monthlyPayable = monthlyPayable;
    if (status != null) c.status = status;
    if (agreementTerms != null) c.agreementTerms = agreementTerms;
    if (paymentTerms != null) c.paymentTerms = paymentTerms;
    if (contactName != null ||
        contactEmail != null ||
        contactPhone != null ||
        contactAddress != null ||
        contactWebsite != null) {
      c.contact = ClientContact(
        name: contactName ?? c.contact.name,
        email: contactEmail ?? c.contact.email,
        phone: contactPhone ?? c.contact.phone,
        address: contactAddress ?? c.contact.address,
        website: contactWebsite ?? c.contact.website,
      );
    }
    if (paymentsDue != null) c.paymentsDue = paymentsDue;
    if (weeklyReels != null) c.weeklyReels = weeklyReels;
    if (weeklyPosts != null) c.weeklyPosts = weeklyPosts;
    if (weeklyCarousels != null) c.weeklyCarousels = weeklyCarousels;
    if (weeklyStories != null) c.weeklyStories = weeklyStories;
    if (campaigns != null) c.campaigns = campaigns;
    if (campaignReach != null) c.campaignReach = campaignReach;
    if (postRequirements != null) c.postRequirements = postRequirements;
    if (conversionProbability != null)
      c.conversionProbability = conversionProbability;
    if (retentionHealth != null) c.retentionHealth = retentionHealth;
    if (nextDueDate != null) c.nextDueDate = nextDueDate;
    if (paymentMode != null) c.paymentMode = paymentMode;
    if (dueDateDay != null) c.dueDateDay = dueDateDay;
    if (assignedVideographerId != null)
      c.assignedVideographerId = assignedVideographerId;
    if (sessionRate != null) c.sessionRate = sessionRate;
    if (serviceType != null) c.serviceType = serviceType;
    if (hasMarketingCommission != null)
      c.hasMarketingCommission = hasMarketingCommission;
    if (marketingExecutiveId != null)
      c.marketingExecutiveId = marketingExecutiveId;
    if (source != null) c.source = source;
    if (isApprovedByCeo != null) c.isApprovedByCeo = isApprovedByCeo;
    if (contractDate != null) c.contractDate = contractDate;
    if (previousStatus != null) c.previousStatus = previousStatus;
    if (paidTill != null) c.paidTill = paidTill;
    if (ecomPaymentType != null) c.ecomPaymentType = ecomPaymentType;
    if (clientSkuRate != null) c.clientSkuRate = clientSkuRate;
    if (clientDuplicateSkuRate != null)
      c.clientDuplicateSkuRate = clientDuplicateSkuRate;
    if (clientCatalogueRate != null)
      c.clientCatalogueRate = clientCatalogueRate;
    if (isWebsiteHandlingActive != null)
      c.isWebsiteHandlingActive = isWebsiteHandlingActive;
    if (websiteHandlingFee != null) c.websiteHandlingFee = websiteHandlingFee;

    _db.collection('clients').doc(clientId).update(c.toFirestore());
    _addLog('CLIENT UPDATED: ${c.name} by ${_activePersona.name}');
    _addNotification('Client updated: ${c.name}', 'client_updated');
    notifyListeners();
  }

  void toggleClientPaidStatus(String clientId, bool isPaid) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx == -1) return;

    final c = _clients[idx];
    if (c.isPaidForMonth == isPaid) return;

    c.isPaidForMonth = isPaid;
    _db.collection('clients').doc(clientId).update({'isPaidForMonth': isPaid});

    if (isPaid) {
      // Record ledger entry
      addFinance(
        FinanceEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: 'Monthly payment received from ${c.name}',
          amount: c.getPayableForMonth(
            DateTime.now().month,
            DateTime.now().year,
          ),
          isIncome: true,
          date: DateTime.now(),
          category: 'Client Payment',
          clientId: c.id,
        ),
      );
      _addLog('CLIENT PAYMENT: ${c.name} marked as PAID');
      _addNotification(
        'Payment received! ${c.name} paid \u20B9${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)}',
        'payment_received',
      );
    } else {
      _addLog('CLIENT PAYMENT: ${c.name} marked as UNPAID');
    }
    notifyListeners();
  }

  void toggleClientPaidMonth(
    String clientId,
    int month, [
    String? paymentMethod,
    DateTime? paymentDate,
    double? amountOverride,
    double discountAmount = 0,
  ]) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx == -1) return;

    final c = _clients[idx];
    final newList = List<int>.from(c.paidMonths);
    final isPaid = newList.contains(month);

    if (isPaid) {
      newList.remove(month);
      c.monthlyDiscounts.remove(month.toString());
      _addLog('CLIENT PAYMENT: ${c.name} marked as UNPAID for Month $month');
    } else {
      newList.add(month);
      if (discountAmount > 0) {
        c.monthlyDiscounts[month.toString()] = discountAmount;
      }

      final basePayable =
          amountOverride ??
          c.getPayableForMonth(month, (paymentDate ?? DateTime.now()).year);
      final finalPaidAmount = basePayable - discountAmount;

      // Record ledger entry
      addFinance(
        FinanceEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: 'Payment received from ${c.name} for Month $month',
          amount: finalPaidAmount,
          isIncome: true,
          date: paymentDate ?? DateTime.now(),
          category: 'Client Payment',
          clientId: c.id,
          paymentMethod: paymentMethod,
        ),
      );
      _addLog('CLIENT PAYMENT: ${c.name} marked as PAID for Month $month');
      _addNotification(
        'Payment received! ${c.name} paid \u20B9${finalPaidAmount.toStringAsFixed(0)} for Month $month',
        'payment_received',
      );
    }

    c.paidMonths = newList;

    // Dynamically calculate paidTill string for ME Dashboard Tracker
    String updatedPaidTill = '';
    if (newList.isNotEmpty) {
      final maxMonth = newList.reduce((a, b) => a > b ? a : b);
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      updatedPaidTill = '${monthNames[maxMonth - 1]} ${DateTime.now().year}';
    }
    c.paidTill = updatedPaidTill;

    _db.collection('clients').doc(clientId).update({
      'paidMonths': newList,
      'paidTill': updatedPaidTill,
      'monthlyDiscounts': c.monthlyDiscounts,
    });
    notifyListeners();
  }

  void addClientAddOn(String clientId, ClientAddOn addOn) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      _clients[idx].addOns.add(addOn);
      _db.collection('clients').doc(clientId).update({
        'addOns': _clients[idx].addOns.map((e) => e.toMap()).toList(),
      });
      _addLog(
        'ADD-ON ADDED: ${addOn.type} (\u20B9${addOn.amount}) for ${_clients[idx].name}',
      );
      notifyListeners();
    }
  }

  void deleteClientAddOn(String clientId, String addOnId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      _clients[idx].addOns.removeWhere((a) => a.id == addOnId);
      _db.collection('clients').doc(clientId).update({
        'addOns': _clients[idx].addOns.map((e) => e.toMap()).toList(),
      });
      _addLog('ADD-ON REMOVED: ID $addOnId for ${_clients[idx].name}');
      notifyListeners();
    }
  }

  Future<void> payClientAddOn(
    String clientId,
    String addOnId,
    String paymentMethod,
    DateTime paymentDate, {
    double? amountPaid,
    double discountAmount = 0.0,
  }) async {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx == -1) return;
    final c = _clients[idx];

    final addOnIdx = c.addOns.indexWhere((a) => a.id == addOnId);
    if (addOnIdx == -1) return;

    final addOn = c.addOns[addOnIdx];
    addOn.discount = discountAmount; // Save discount
    
    final originalAmount = addOn.amount - discountAmount;
    final payAmount = amountPaid ?? originalAmount;

    if (payAmount >= originalAmount) {
      addOn.isPaid = true;
    } else {
      addOn.amount -= payAmount;
    }

    addFinance(
      FinanceEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '-addon',
        label:
            'Payment received for Add-On: ${addOn.type} - ${c.name}${payAmount < originalAmount ? ' (Partial)' : ''}',
        amount: payAmount,
        isIncome: true,
        date: paymentDate,
        category: 'Client Payment',
        clientId: c.id,
        paymentMethod: paymentMethod,
        serviceType: addOn.type,
      ),
    );

    _addLog('ADD-ON PAYMENT: ${c.name} paid for Add-On ${addOn.type}');
    _addNotification(
      'Add-On Payment received! ${c.name} paid \u20B9${addOn.amount.toStringAsFixed(0)} for ${addOn.type}',
      'payment_received',
    );

    await _db.collection('clients').doc(clientId).update({
      'addOns': c.addOns.map((e) => e.toMap()).toList(),
    });
    notifyListeners();
  }

  Future<void> markAddOnsAsBilled(
    String clientId,
    List<String> addOnIds,
  ) async {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx == -1) return;
    final c = _clients[idx];

    bool changed = false;
    for (var addOn in c.addOns) {
      if (addOnIds.contains(addOn.id)) {
        addOn.isBilled = true;
        changed = true;
      }
    }

    if (changed) {
      await _db.collection('clients').doc(clientId).update({
        'addOns': c.addOns.map((e) => e.toMap()).toList(),
      });
      notifyListeners();
    }
  }

  Future<void> processAddOnPayments(
    String clientId,
    List<String> fullyBilledIds,
    Map<String, double> partialPayments,
  ) async {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx == -1) return;
    final c = _clients[idx];

    bool changed = false;
    for (var addOn in c.addOns) {
      if (fullyBilledIds.contains(addOn.id)) {
        addOn.isBilled = true;
        changed = true;
      } else if (partialPayments.containsKey(addOn.id)) {
        double partialAmt = partialPayments[addOn.id]!;
        if (partialAmt > 0 && partialAmt < addOn.amount) {
          addOn.amount -= partialAmt; // Deduct partial payment
          changed = true;
        } else if (partialAmt >= addOn.amount) {
          addOn.isBilled = true; // Fully paid
          changed = true;
        }
      }
    }

    if (changed) {
      await _db.collection('clients').doc(clientId).update({
        'addOns': c.addOns.map((e) => e.toMap()).toList(),
      });
      notifyListeners();
    }
  }

  void addClientFollowUp(String clientId, String date) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      _clients[idx].followUpDates = [date, ..._clients[idx].followUpDates];
      _db.collection('clients').doc(clientId).update({
        'followUpDates': _clients[idx].followUpDates,
      });
      _addLog('FOLLOW-UP ADDED: ${_clients[idx].name} on $date');
      _addNotification(
        'Follow-up scheduled: ${_clients[idx].name} on $date',
        'general',
      );
      notifyListeners();
    }
  }

  void addClientNote(String clientId, String note) {
    if (note.trim().isEmpty) return;
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      _clients[idx].notes = [
        '[${DateTime.now().toString().substring(0, 10)}] $note',
        ..._clients[idx].notes,
      ];
      _db.collection('clients').doc(clientId).update({
        'notes': _clients[idx].notes,
      });
      _addLog('NOTE ADDED: ${_clients[idx].name}');
      notifyListeners();
    }
  }

  void removeClient(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final name = _clients[idx].name;
      _db.collection('clients').doc(clientId).delete();
      _addLog('CLIENT REMOVED: $name by ${_activePersona.name}');
      _addNotification('Client removed: $name', 'client_removed');
    }
  }

  // --- Finance ---
  final List<FinanceEntry> _finances = [];

  List<FinanceEntry> get finances => List.unmodifiable(_finances);

  double get totalIncome =>
      _finances.where((f) => f.isIncome).fold(0.0, (s, f) => s + f.amount);
  double get totalExpenses =>
      _finances.where((f) => !f.isIncome).fold(0, (s, f) => s + f.amount);
  double get netBalance => totalIncome - totalExpenses;

  PoolData get mainPool {
    double inc = 0, exp = 0;
    double ritam = 0.0, priyajit = 0.0, marketingEx = 0.0;
    for (var f in _finances) {
      String serviceType = f.serviceType ?? 'Miscellaneous';
      String? meId = f.marketingExecutiveId;
      if (f.clientId != null) {
        final c = _clients.firstWhere(
          (cl) => cl.id == f.clientId,
          orElse: () => Client(
            id: '',
            name: '',
            contact: ClientContact(name: '', email: '', phone: ''),
            contractDate: DateTime.now(),
          ),
        );
        if (c.id.isNotEmpty) {
          serviceType = f.serviceType ?? c.serviceType;
          meId = c.marketingExecutiveId;
        }
      } else {
        Client? matchedClient;
        for (var cl in _clients) {
          if (f.label.contains(cl.name)) {
            matchedClient = cl;
            break;
          }
        }
        if (matchedClient != null) {
          serviceType = f.serviceType ?? matchedClient.serviceType;
          meId = matchedClient.marketingExecutiveId;
        }
      }

      if (serviceType == 'Video Production') continue;

      if (f.isIncome) {
        inc += f.amount;
        double amt = f.amount;
        double pAmt = amt;
        if (serviceType == 'Marketing' && meId != null && meId.isNotEmpty) {
          double comm = amt * 0.20;
          marketingEx += comm;
          pAmt -= comm;
        }
        if (serviceType.toLowerCase().contains('commerce')) {
          ritam += pAmt * 0.80;
          priyajit += pAmt * 0.20;
        } else {
          ritam += pAmt * 0.50;
          priyajit += pAmt * 0.50;
        }
      } else {
        if (f.category == 'Commission') continue;
        exp += f.amount;
        if (serviceType.toLowerCase().contains('commerce')) {
          ritam -= f.amount * 0.80;
          priyajit -= f.amount * 0.20;
        } else {
          ritam -= f.amount * 0.50;
          priyajit -= f.amount * 0.50;
        }
      }
    }
    return PoolData(
      income: inc,
      expenses: exp,
      shares: {
        'ritam': ritam,
        'priyajit': priyajit,
        'marketingEx': marketingEx,
      },
    );
  }

  PoolData get videoPool {
    double inc = 0, exp = 0;
    double ritam = 0.0, priyajit = 0.0;
    for (var f in _finances) {
      String serviceType = f.serviceType ?? 'Miscellaneous';
      if (f.clientId != null) {
        final c = _clients.firstWhere(
          (cl) => cl.id == f.clientId,
          orElse: () => Client(
            id: '',
            name: '',
            contact: ClientContact(name: '', email: '', phone: ''),
            contractDate: DateTime.now(),
          ),
        );
        if (c.id.isNotEmpty) {
          serviceType = f.serviceType ?? c.serviceType;
        }
      } else {
        Client? matchedClient;
        for (var cl in _clients) {
          if (f.label.contains(cl.name)) {
            matchedClient = cl;
            break;
          }
        }
        if (matchedClient != null) {
          serviceType = f.serviceType ?? matchedClient.serviceType;
        }
      }

      if (serviceType != 'Video Production') continue;

      if (f.isIncome) {
        inc += f.amount;
        double amt = f.amount;
        ritam += amt * 0.20;
        priyajit += amt * 0.80;
      } else {
        if (f.category == 'Commission') continue;
        exp += f.amount;
        ritam -= f.amount * 0.20;
        priyajit -= f.amount * 0.80;
      }
    }
    return PoolData(
      income: inc,
      expenses: exp,
      shares: {'ritam': ritam, 'priyajit': priyajit},
    );
  }

  Map<String, double> get profitShares {
    double ritam = 0.0;
    double priyajit = 0.0;
    double marketingEx = 0.0;

    // 1. Process all finance entries for R&P cumulative (matches ledger exactly)
    for (var f in _finances) {
      if (f.isIncome) {
        double amt = f.amount;
        double pAmt = amt;

        // Determine service type and ME from the FinanceEntry or matching Client
        String serviceType = f.serviceType ?? 'Miscellaneous';
        String? meId = f.marketingExecutiveId;

        if (f.clientId != null) {
          final c = _clients.firstWhere(
            (cl) => cl.id == f.clientId,
            orElse: () => Client(
              id: '',
              name: '',
              contact: ClientContact(name: '', email: '', phone: ''),
              contractDate: DateTime.now(),
            ),
          );
          if (c.id.isNotEmpty) {
            serviceType = f.serviceType ?? c.serviceType;
            meId = c.marketingExecutiveId;
          }
        } else {
          Client? matchedClient;
          for (var cl in _clients) {
            if (f.label.contains(cl.name)) {
              matchedClient = cl;
              break;
            }
          }
          if (matchedClient != null) {
            serviceType = matchedClient.serviceType;
            meId = matchedClient.marketingExecutiveId;
          }
        }

        // Apply ME commission ONLY if serviceType is Marketing
        if (serviceType == 'Marketing' && meId != null && meId.isNotEmpty) {
          double comm = amt * 0.20;
          marketingEx += comm;
          pAmt -= comm;
        }

        // Apply co-founder splits based on serviceType
        if (serviceType.toLowerCase().contains('commerce')) {
          ritam += pAmt * 0.80;
          priyajit += pAmt * 0.20;
        } else if (serviceType == 'Video Production') {
          ritam += pAmt * 0.20;
          priyajit += pAmt * 0.80;
        } else {
          ritam += pAmt * 0.50;
          priyajit += pAmt * 0.50;
        }
      } else {
        // Skip actual commission payouts from R&P deduction (they belong to ME)
        if (f.category == 'Commission') continue;

        ritam -= f.amount * 0.50;
        priyajit -= f.amount * 0.50;
      }
    }

    return {'ritam': ritam, 'priyajit': priyajit, 'marketingEx': marketingEx};
  }

  void approveClientConversion(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final c = _clients[idx];
      c.isApprovedByCeo = true;
      c.status = 'Active';
      _db.collection('clients').doc(clientId).update({
        'isApprovedByCeo': true,
        'status': 'Active',
      });
      _addLog('CLIENT CONVERSION APPROVED: ${c.name}');
      _addNotification(
        'Conversion approved for client: ${c.name}',
        'client_updated',
      );
      notifyListeners();
    }
  }

  void rejectClientConversion(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final c = _clients[idx];
      final prev = c.previousStatus ?? 'Lead';
      c.isApprovedByCeo = false;
      c.status = prev;
      _db.collection('clients').doc(clientId).update({
        'isApprovedByCeo': false,
        'status': prev,
      });
      _addLog('CLIENT CONVERSION REJECTED: ${c.name} (reverted to ${prev})');
      _addNotification(
        'Conversion rejected for client: ${c.name}',
        'client_updated',
      );
      notifyListeners();
    }
  }

  void clearMarketingCommission(
    String employeeId,
    String month,
    double amount,
  ) {
    final idx = _employees.indexWhere((e) => e.id == employeeId);
    if (idx != -1) {
      final e = _employees[idx];
      e.pendingPayMonth = month;
      e.pendingPayAmount = amount;
      e.paymentCleared = true;
      e.paymentApprovedByEmployee = false;
      _db.collection('employees').doc(employeeId).update({
        'pendingPayMonth': month,
        'pendingPayAmount': amount,
        'paymentCleared': true,
        'paymentApprovedByEmployee': false,
      });
      _addLog(
        'COMMISSION PAYOUT CLEARED: ${e.name} for ${month} (\u20B9${amount.toStringAsFixed(0)})',
      );
      _addNotification(
        'Commission cleared for ${e.name}: \u20B9${amount.toStringAsFixed(0)}',
        'payment',
      );
      notifyListeners();
    }
  }

  void approveMarketingCommission(String employeeId) {
    final idx = _employees.indexWhere((e) => e.id == employeeId);
    if (idx != -1) {
      final e = _employees[idx];
      final month = e.pendingPayMonth ?? 'Unknown';
      final amt = e.pendingPayAmount;

      final newList = List<String>.from(e.paidMonths);
      if (!newList.contains(month)) {
        newList.add(month);
      }

      e.paidMonths = newList;
      e.paymentApprovedByEmployee = true;
      e.paymentCleared = false;

      _db.collection('employees').doc(employeeId).update({
        'paidMonths': newList,
        'paymentApprovedByEmployee': true,
        'paymentCleared': false,
        'pendingPayMonth': FieldValue.delete(),
        'pendingPayAmount': 0.0,
      });

      // Record outflow in ledger
      addFinance(
        FinanceEntry(
          id:
              'FIN-COMM-' +
              DateTime.now().millisecondsSinceEpoch.toString().substring(8),
          label: 'Commission payout to ${e.name} for Month ${month}',
          amount: amt,
          isIncome: false,
          date: DateTime.now(),
          category: 'Commission',
          employeeId: e.id,
          paymentMonth: month,
        ),
      );

      e.pendingPayMonth = null;
      e.pendingPayAmount = 0.0;

      _addLog('COMMISSION PAYOUT APPROVED: ${e.name} for Month ${month}');
      _addNotification(
        'Commission paid to ${e.name} for Month ${month}',
        'payment',
      );
      notifyListeners();
    }
  }

  double get currentMonthExpectedRevenue {
    return _clients
        .where((c) => c.status != 'Lead')
        .fold(
          0.0,
          (s, c) =>
              s +
              c.getPayableForMonth(DateTime.now().month, DateTime.now().year),
        );
  }

  double get currentMonthCollectedRevenue {
    final now = DateTime.now();
    return _finances
        .where(
          (f) =>
              f.isIncome &&
              f.date.month == now.month &&
              f.date.year == now.year,
        )
        .fold(0.0, (s, f) => s + f.amount);
  }

  double get deficit {
    final def = currentMonthExpectedRevenue - currentMonthCollectedRevenue;
    return def > 0 ? def : 0.0;
  }

  void addFinance(FinanceEntry entry) {
    _db.collection('finances').doc(entry.id).set(entry.toFirestore());
    _addLog(
      'FINANCE ADDED: ${entry.label} [${entry.isIncome ? '+' : '-'}${entry.amount}]',
    );
    _addNotification(
      'Finance entry: ${entry.label} [${entry.isIncome ? '+' : '-'}\u20B9${entry.amount.toStringAsFixed(0)}]',
      'finance',
    );

    // --- Auto-adjustments based on ledger entries ---
    if (entry.isIncome) {
      if (entry.incomeType == 'Monthly Payment' && entry.clientId != null) {
        final cIdx = _clients.indexWhere((c) => c.id == entry.clientId);
        if (cIdx != -1) {
          final client = _clients[cIdx];
          final newDue = max(0, client.paymentsDue - 1);
          updateClientPaymentsDue(client.id, newDue);
        }
      }
    } else {
      if (entry.expenseType == 'Salary' && entry.employeeId != null) {
        final eIdx = _employees.indexWhere((e) => e.id == entry.employeeId);
        if (eIdx != -1) {
          final employee = _employees[eIdx];
          if (entry.isSessionBased == true && entry.sessionCount != null) {
            // Videographer: increment sessions paid
            final newSessionsPaid = employee.sessionsPaid + entry.sessionCount!;
            updateEmployeeSessionsPaid(employee.id, newSessionsPaid);
          } else if (entry.paymentMonth != null) {
            // Editor: mark month as paid
            final upperMonth = entry.paymentMonth!.toUpperCase();
            String? monthCode;
            final codes = [
              'JAN',
              'FEB',
              'MAR',
              'APR',
              'MAY',
              'JUN',
              'JUL',
              'AUG',
              'SEP',
              'OCT',
              'NOV',
              'DEC',
            ];
            final fullNames = [
              'JANUARY',
              'FEBRUARY',
              'MARCH',
              'APRIL',
              'MAY',
              'JUNE',
              'JULY',
              'AUGUST',
              'SEPTEMBER',
              'OCTOBER',
              'NOVEMBER',
              'DECEMBER',
            ];
            for (int i = 0; i < 12; i++) {
              if (upperMonth.contains(codes[i]) ||
                  upperMonth.contains(fullNames[i]) ||
                  upperMonth.contains(
                    '-${(i + 1).toString().padLeft(2, '0')}',
                  )) {
                monthCode = codes[i];
                break;
              }
            }
            if (monthCode != null) {
              final list = List<String>.from(employee.paidMonths);
              if (!list.contains(monthCode)) {
                list.add(monthCode);
                _employees[eIdx].paidMonths = list;
                _db.collection('employees').doc(employee.id).update({
                  'paidMonths': list,
                });
                _addLog('AUTO-MARKED PAID: ${employee.name} for $monthCode');
              }
            }
          }
        }
      }
    }
  }

  void removeFinance(String entryId) {
    final idx = _finances.indexWhere((f) => f.id == entryId);
    if (idx != -1) {
      _addLog('FINANCE DELETED: ${_finances[idx].label}');
      _db.collection('finances').doc(entryId).delete();
    }
  }

  // --- Notifications ---
  final List<SageNotification> _notifications = [];

  final Set<String> _hiddenNotificationIds = {};

  List<SageNotification> get notifications => _notifications
      .where((n) => !_hiddenNotificationIds.contains(n.id))
      .toList();

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  void markNotificationRead(String notifId) {
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      _db.collection('notifications').doc(notifId).update({'isRead': true});
      notifyListeners();
    }
  }

  void clearNotifications() {
    for (var n in _notifications) {
      _hiddenNotificationIds.add(n.id);
    }
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        _db.collection('notifications').doc(n.id).update({'isRead': true});
      }
    }
    notifyListeners();
  }

  void _addNotification(String message, String type) {
    final notif = SageNotification(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      type: type,
      timestamp: DateTime.now(),
      triggeredBy: _activePersona.name,
    );
    _notifications.insert(0, notif);
    notifyListeners();
    _db.collection('notifications').add(notif.toFirestore());
    AudioService.playNotification(type);
  }

  // --- System Logs ---
  final List<String> _logs = [
    '> SYSTEM BOOT... OK',
    '> ALL COLLECTIONS SYNCED TO CLOUD',
  ];

  List<String> get logs => List.unmodifiable(_logs);

  void _addLog(String entry) {
    _logs.add('> ${DateTime.now().toString().substring(11, 16)} - $entry');
    if (_logs.length > 50) _logs.removeAt(0);
  }

  // --- Admin PIN ---
  static const String adminPin = '8992';

  bool verifyAdminPin(String pin) => pin == adminPin;

  Future<void> revertEmployeePaymentState(String empId) async {
    final tasksSnap = await _db
        .collection('tasks')
        .where('assignedTo', isEqualTo: empId)
        .get();
    for (var doc in tasksSnap.docs) {
      doc.reference.update({'isPaidToVideographer': false});
    }
    _db.collection('employees').doc(empId).update({
      'paymentCleared': false,
      'paymentApprovedByEmployee': false,
      'pendingPayAmount': 0.0,
      'pendingPayMonth': FieldValue.delete(),
    });
    // Update local state too
    final idx = _employees.indexWhere((e) => e.id == empId);
    if (idx != -1) {
      _employees[idx].paymentCleared = false;
      _employees[idx].paymentApprovedByEmployee = false;
      _employees[idx].pendingPayAmount = 0.0;
      _employees[idx].pendingPayMonth = null;
    }
    for (var t in _tasks.where((t) => t.assignedTo == empId)) {
      t.isPaidToVideographer = false;
    }
    notifyListeners();
  }

  // --- Archiving -------------------------------------------------------------

  void archiveCurrentLedger(String monthYear) async {
    final batch = _db.batch();
    for (var entry in _finances) {
      final docRef = _db.collection('archived_finances').doc();
      final data = entry.toFirestore();
      data['archiveMonth'] = monthYear; // Tag with monthYear
      batch.set(docRef, data);

      // Delete from active finances
      final activeRef = _db.collection('finances').doc(entry.id);
      batch.delete(activeRef);
    }
    await batch.commit();
    _addLog('ARCHIVED: Ledger logs for $monthYear');
  }

  void archiveNotifications(String monthYear) async {
    final batch = _db.batch();
    for (var entry in _notifications) {
      final docRef = _db.collection('archived_notifications').doc();
      final data = entry.toFirestore();
      data['archiveMonth'] = monthYear; // Tag with monthYear
      batch.set(docRef, data);

      // Delete from active notifications
      final activeRef = _db.collection('notifications').doc(entry.id);
      batch.delete(activeRef);
    }
    await batch.commit();
    _addLog('ARCHIVED: Notifications for $monthYear');
  }

  void deleteLedgerArchive(String monthYear) async {
    final query = await _db
        .collection('archived_finances')
        .where('archiveMonth', isEqualTo: monthYear)
        .get();
    final batch = _db.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _addLog('DELETED: Ledger archive for $monthYear');
  }

  void deleteNotificationArchive(String monthYear) async {
    final query = await _db
        .collection('archived_notifications')
        .where('archiveMonth', isEqualTo: monthYear)
        .get();
    final batch = _db.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _addLog('DELETED: Notification archive for $monthYear');
  }

  // --- Executive Profiles ---
  void updatePersona(Persona p) async {
    final index = personas.indexWhere((element) => element.id == p.id);
    if (index != -1) {
      personas[index] = p;
    }
    await _db.collection('executive_profiles').doc(p.id).set(p.toFirestore());
    if (_activePersona?.id == p.id) {
      _activePersona = p;
      notifyListeners();
    }
    _addLog('Updated profile for ${p.name}');
  }

  void _playNotificationSound(SageNotification notif) async {
    try {
      final msg = notif.message.toLowerCase();
      String audioAsset = 'audio/general.mp3';

      if (msg.contains('task')) {
        audioAsset = 'audio/new_task.mp3';
      } else if (msg.contains('session')) {
        audioAsset = 'audio/new_session_booking.mp3';
      }

      _audioPlayer.play(AssetSource(audioAsset));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  void updateEmployeePersonal(
    String id, {
    String? name,
    String? address,
    String? phone,
    String? email,
    String? preferredName,
    String? emergencyContact,
    String? professionalBio,
    String? workLocation,
    String? workStylePreference,
    String? interests,
    List<String>? keySkills,
    List<String>? strengths,
    int? avatar,
  }) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final old = _employees[idx];
      _employees[idx] = Employee(
        id: old.id,
        name: name ?? old.name,
        password: old.password,
        role: old.role,
        department: old.department,
        monthlySalary: old.monthlySalary,
        address: address ?? old.address,
        phone: phone ?? old.phone,
        email: email ?? old.email,
        preferredName: preferredName ?? old.preferredName,
        emergencyContact: emergencyContact ?? old.emergencyContact,
        professionalBio: professionalBio ?? old.professionalBio,
        workLocation: workLocation ?? old.workLocation,
        workStylePreference: workStylePreference ?? old.workStylePreference,
        interests: interests ?? old.interests,
        keySkills: keySkills ?? old.keySkills,
        strengths: strengths ?? old.strengths,
        avatar: avatar ?? old.avatar,
        paymentCleared: old.paymentCleared,
        paidMonths: old.paidMonths,
      );
      // Use .update() with only personal fields to avoid overwriting financial data
      _db.collection('employees').doc(id).update({
        if (name != null) 'name': _employees[idx].name,
        if (address != null) 'address': _employees[idx].address,
        if (phone != null) 'phone': _employees[idx].phone,
        if (email != null) 'email': _employees[idx].email,
        if (preferredName != null)
          'preferredName': _employees[idx].preferredName,
        if (emergencyContact != null)
          'emergencyContact': _employees[idx].emergencyContact,
        if (professionalBio != null)
          'professionalBio': _employees[idx].professionalBio,
        if (workLocation != null) 'workLocation': _employees[idx].workLocation,
        if (workStylePreference != null)
          'workStylePreference': _employees[idx].workStylePreference,
        if (interests != null) 'interests': _employees[idx].interests,
        if (keySkills != null) 'keySkills': _employees[idx].keySkills,
        if (strengths != null) 'strengths': _employees[idx].strengths,
        if (avatar != null) 'avatar': _employees[idx].avatar,
      });
      notifyListeners();
    }
  }

  // --- Lead Termination Requests ---
  void requestLeadTermination(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final c = _clients[idx];
      c.isTerminationRequested = true;
      _db.collection('clients').doc(clientId).update({
        'isTerminationRequested': true,
      });
      _addLog('LEAD TERMINATION REQUESTED: ${c.name}');
      _addNotification(
        'Termination requested for lead: ${c.name}',
        'client_updated',
      );
      notifyListeners();
    }
  }

  void approveLeadTermination(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final c = _clients[idx];
      _db.collection('clients').doc(clientId).delete();
      _clients.removeAt(idx);
      _addLog('LEAD TERMINATION APPROVED AND DELETED: ${c.name}');
      _addNotification('Lead deleted: ${c.name}', 'client_updated');
      notifyListeners();
    }
  }

  void rejectLeadTermination(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final c = _clients[idx];
      c.isTerminationRequested = false;
      _db.collection('clients').doc(clientId).update({
        'isTerminationRequested': false,
      });
      _addLog('LEAD TERMINATION REJECTED: ${c.name}');
      _addNotification(
        'Termination rejected for lead: ${c.name}',
        'client_updated',
      );
      notifyListeners();
    }
  }
}
