// SAGE Mainframe ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Data Models
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Persona / Role ----------------------------------------------------------
DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

DateTime? _parseDateNullable(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

enum PersonaRole { ceo, cofounder, employee }

const List<String> availableAvatars = [
  'assets/avatars/4t.png',
  'assets/avatars/5y.png',
  'assets/avatars/6y.png',
  'assets/avatars/7i.png',
  'assets/avatars/d.png',
  'assets/avatars/df.png',
  'assets/avatars/gd.png',
];

class Persona {
  final String id;
  String name;
  final PersonaRole role;
  String initials;
  String password;
  
  // Executive Profile Fields
  String phone;
  String email;
  String address;
  String dob;
  String gender;
  int avatar;
  String preferredName;
  String emergencyContact;
  String professionalBio;
  String workLocation;
  String workStylePreference;
  String interests;
  List<String> keySkills;
  List<String> strengths;

  Persona({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    required this.password,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.dob = '',
    this.gender = '',
    this.avatar = 0,
    this.preferredName = '',
    this.emergencyContact = '',
    this.professionalBio = '',
    this.workLocation = 'Office',
    this.workStylePreference = 'Independent thinker',
    this.interests = '',
    this.keySkills = const [],
    this.strengths = const [],
  });

  factory Persona.fromFirestore(Map<String, dynamic> data, String docId) {
    PersonaRole pRole;
    switch (data['role']) {
      case 'CEO': pRole = PersonaRole.ceo; break;
      case 'CO-FOUNDER': pRole = PersonaRole.cofounder; break;
      case 'EMPLOYEE': pRole = PersonaRole.employee; break;
      default: 
        print('WARNING: Unknown persona role: ${data["role"]} - defaulting to EMPLOYEE');
        pRole = PersonaRole.employee; 
        break;
    }
    return Persona(
      id: docId,
      name: data['name'] ?? '',
      role: pRole,
      initials: data['initials'] ?? '',
      password: data['password'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      dob: data['dob'] ?? '',
      gender: data['gender'] ?? '',
      avatar: (data['avatar'] is int) ? ((data['avatar'] as int).clamp(0, 6)) : 0,
      preferredName: data['preferredName'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      professionalBio: data['professionalBio'] ?? '',
      workLocation: data['workLocation'] ?? 'Office',
      workStylePreference: data['workStylePreference'] ?? 'Independent thinker',
      interests: data['interests'] ?? '',
      keySkills: List<String>.from(data['keySkills'] ?? []),
      strengths: List<String>.from(data['strengths'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    String roleStr;
    switch (role) {
      case PersonaRole.ceo: roleStr = 'CEO'; break;
      case PersonaRole.cofounder: roleStr = 'CO-FOUNDER'; break;
      case PersonaRole.employee: roleStr = 'EMPLOYEE'; break;
      default: roleStr = 'EMPLOYEE'; break;
    }
    return {
      'name': name,
      'role': roleStr,
      'initials': initials,
      'password': password,
      'phone': phone,
      'email': email,
      'address': address,
      'dob': dob,
      'gender': gender,
      'avatar': avatar,
      'preferredName': preferredName,
      'emergencyContact': emergencyContact,
      'professionalBio': professionalBio,
      'workLocation': workLocation,
      'workStylePreference': workStylePreference,
      'interests': interests,
      'keySkills': keySkills,
      'strengths': strengths,
    };
  }

  String get roleLabel {
    switch (role) {
      case PersonaRole.ceo: return 'CEO';
      case PersonaRole.cofounder: return 'CO-FOUNDER';
      case PersonaRole.employee: return 'EMPLOYEE';
    }
  }
}

// --- Employee Record ---------------------------------------------------------
class Employee {
  final String id;
  String name;
  String role;
  String department;
  String password;
  bool isActive;
  double monthlySalary;
  double perSessionRate;
  double perVideoRate;
  double perSkuRate;
  int sessionsPerMonth;
  List<String> paidMonths;
  int sessionsPaid;
  int skusPaid;
  bool paymentCleared;
  bool paymentApprovedByEmployee;
  int paymentsDue;
  DateTime joiningDate;
  DateTime lastPaidDate;
  String address;
  String phone;
  String email;
  int avatar;
  String? pendingPayMonth;
  double pendingPayAmount = 0.0;
  String preferredName;
  String workLocation;
  String emergencyContact;
  String professionalBio;
  List<String> keySkills;
  List<String> strengths;
  String workStylePreference;
  String interests;
  String paymentMode;
  String videoEditorPayType; // 'Salary' or 'Per Video Rate'


  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.password,
    this.isActive = true,
    this.monthlySalary = 0.0,
    this.perSessionRate = 0.0,
    this.perVideoRate = 0.0,
    this.perSkuRate = 0.0,
    this.sessionsPerMonth = 0,
    this.paidMonths = const [],
    this.sessionsPaid = 0,
    this.skusPaid = 0,
    this.paymentCleared = false,
    this.paymentApprovedByEmployee = false,
    this.paymentsDue = 0,
    this.address = '',
    this.phone = '',
    this.email = '',
    this.avatar = 0,
    this.pendingPayMonth,
    this.pendingPayAmount = 0.0,
    this.preferredName = '',
    this.workLocation = '',
    this.emergencyContact = '',
    this.paymentMode = 'Running',
    this.professionalBio = '',
    this.keySkills = const [],
    this.strengths = const [],
    this.workStylePreference = '',
    this.interests = '',
    this.videoEditorPayType = 'Per Video Rate',
    DateTime? joiningDate,
    DateTime? lastPaidDate,
  })  : joiningDate = joiningDate ?? DateTime(2025, 5, 1),
        lastPaidDate = lastPaidDate ?? DateTime.now();

  bool hasRole(String checkRole) {
    final r = role.toLowerCase();
    if (r.contains('ceo') || r.contains('cfo')) return true;
    return r.contains(checkRole.toLowerCase());
  }

  factory Employee.fromFirestore(Map<String, dynamic> data, String docId) {
    return Employee(
      id: data['empId'] ?? docId,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      department: data['department'] ?? '',
      password: data['password'] ?? '',
      isActive: data['isActive'] ?? true,
      monthlySalary: (data['monthlySalary'] ?? 0.0).toDouble(),
      perSessionRate: (data['perSessionRate'] ?? 0.0).toDouble(),
      perVideoRate: (data['perVideoRate'] ?? 0.0).toDouble(),
      perSkuRate: (data['perSkuRate'] ?? 0.0).toDouble(),
      sessionsPerMonth: data['sessionsPerMonth'] ?? 0,
      paidMonths: List<String>.from(data['paidMonths'] ?? []),
      sessionsPaid: data['sessionsPaid'] ?? 0,
      skusPaid: data['skusPaid'] ?? 0,
      paymentCleared: data['paymentCleared'] ?? false,
      paymentApprovedByEmployee: data['paymentApprovedByEmployee'] ?? false,
      paymentsDue: data['paymentsDue'] ?? 0,
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      avatar: (data['avatar'] is int) ? ((data['avatar'] as int).clamp(0, 6)) : 0,
      pendingPayMonth: data['pendingPayMonth'],
      pendingPayAmount: (data['pendingPayAmount'] ?? 0.0).toDouble(),
      preferredName: data['preferredName'] ?? '',
      workLocation: data['workLocation'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      paymentMode: data['paymentMode'] ?? 'Running',
      professionalBio: data['professionalBio'] ?? '',
      keySkills: List<String>.from(data['keySkills'] ?? []),
      strengths: List<String>.from(data['strengths'] ?? []),
      workStylePreference: data['workStylePreference'] ?? '',
      interests: data['interests'] ?? '',
      videoEditorPayType: data['videoEditorPayType'] ?? ((data['monthlySalary'] ?? 0.0) > 0 ? 'Salary' : 'Per Video Rate'),
      joiningDate: (_parseDateNullable(data['joiningDate']) ?? DateTime(2025, 5, 1)),
      lastPaidDate: _parseDate(data['lastPaidDate']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'empId': id,
      'name': name,
      'role': role,
      'department': department,
      'password': password,
      'isActive': isActive,
      'monthlySalary': monthlySalary,
      'perSessionRate': perSessionRate,
      'perVideoRate': perVideoRate,
      'perSkuRate': perSkuRate,
      'sessionsPerMonth': sessionsPerMonth,
      'paidMonths': paidMonths,
      'sessionsPaid': sessionsPaid,
      'skusPaid': skusPaid,
      'videoEditorPayType': videoEditorPayType,
      'paymentCleared': paymentCleared,
      'paymentApprovedByEmployee': paymentApprovedByEmployee,
      'paymentsDue': paymentsDue,
      'address': address,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      if (pendingPayMonth != null) 'pendingPayMonth': pendingPayMonth,
      'pendingPayAmount': pendingPayAmount,
      'preferredName': preferredName,
      'workLocation': workLocation,
      'emergencyContact': emergencyContact,
      'professionalBio': professionalBio,
      'keySkills': keySkills,
      'strengths': strengths,
      'workStylePreference': workStylePreference,
      'interests': interests,

      'paymentMode': paymentMode,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'lastPaidDate': Timestamp.fromDate(lastPaidDate),
    };
  }
}

// ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ Task ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬
class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // employee/cofounder id
  final String assignedBy; // persona id
  final DateTime deadline;
  bool isCompleted;
  bool isSubmitted;
  final DateTime createdAt;
  final String? clientId;
  final String? taskType;
  final String? instructions;
  final DateTime? completedAt;
  final DateTime? rejectedAt;
  final DateTime? submittedAt;
  bool isApprovedByVideographer;
  bool isApprovedByGraphicsEditor;
  final List<String> sessionClientIds; // For sessions: list of client IDs
  bool isPostponeRequested;
  final DateTime? postponeRequestedDate;
  bool isPaidToVideographer = false;
  bool isPaymentAcknowledgedByVideographer = false;
  bool isPaidToGraphicsEditor = false;
  bool isPaymentAcknowledgedByGraphicsEditor = false;
  String? uploadTaskId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedBy,
    required this.deadline,
    this.isCompleted = false,
    this.isSubmitted = false,
    DateTime? createdAt,
    this.clientId,
    this.taskType,
    this.instructions,
    this.completedAt,
    this.rejectedAt,
    this.submittedAt,
    this.isApprovedByVideographer = false,
    this.isApprovedByGraphicsEditor = false,
    this.isPaidToVideographer = false,
    this.isPaymentAcknowledgedByVideographer = false,
    this.isPaidToGraphicsEditor = false,
    this.isPaymentAcknowledgedByGraphicsEditor = false,
    this.sessionClientIds = const [],
    this.isPostponeRequested = false,
    this.postponeRequestedDate,
    this.uploadTaskId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Task.fromFirestore(Map<String, dynamic> data, String docId) {
    return Task(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      assignedBy: data['assignedBy'] ?? '',
      deadline: _parseDate(data['deadline']),
      isCompleted: data['isCompleted'] ?? false,
      isSubmitted: data['isSubmitted'] ?? false,
      createdAt: _parseDate(data['createdAt']),
      clientId: data['clientId'],
      taskType: data['taskType'],
      instructions: data['instructions'],
      completedAt: _parseDateNullable(data['completedAt']),
      rejectedAt: _parseDateNullable(data['rejectedAt']),
      submittedAt: _parseDateNullable(data['submittedAt']),
      isApprovedByVideographer: data['isApprovedByVideographer'] ?? false,
      isApprovedByGraphicsEditor: data['isApprovedByGraphicsEditor'] ?? false,
      isPaidToVideographer: data['isPaidToVideographer'] ?? false,
      isPaymentAcknowledgedByVideographer: data['isPaymentAcknowledgedByVideographer'] ?? false,
      isPaidToGraphicsEditor: data['isPaidToGraphicsEditor'] ?? false,
      isPaymentAcknowledgedByGraphicsEditor: data['isPaymentAcknowledgedByGraphicsEditor'] ?? false,
      sessionClientIds: List<String>.from(data['sessionClientIds'] ?? []),
      isPostponeRequested: data['isPostponeRequested'] ?? false,
      postponeRequestedDate: _parseDateNullable(data['postponeRequestedDate']),
      uploadTaskId: data['uploadTaskId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'deadline': Timestamp.fromDate(deadline),
      'isCompleted': isCompleted,
      'isSubmitted': isSubmitted,
      'createdAt': Timestamp.fromDate(createdAt),
      if (clientId != null) 'clientId': clientId,
      if (taskType != null) 'taskType': taskType,
      if (instructions != null) 'instructions': instructions,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (rejectedAt != null) 'rejectedAt': Timestamp.fromDate(rejectedAt!),
      if (submittedAt != null) 'submittedAt': Timestamp.fromDate(submittedAt!),
      'isApprovedByVideographer': isApprovedByVideographer,
      'isApprovedByGraphicsEditor': isApprovedByGraphicsEditor,
      'isPaidToVideographer': isPaidToVideographer,
      'isPaymentAcknowledgedByVideographer': isPaymentAcknowledgedByVideographer,
      'isPaidToGraphicsEditor': isPaidToGraphicsEditor,
      'isPaymentAcknowledgedByGraphicsEditor': isPaymentAcknowledgedByGraphicsEditor,
      if (sessionClientIds.isNotEmpty) 'sessionClientIds': sessionClientIds,
      'isPostponeRequested': isPostponeRequested,
      if (postponeRequestedDate != null) 'postponeRequestedDate': Timestamp.fromDate(postponeRequestedDate!),
      if (uploadTaskId != null) 'uploadTaskId': uploadTaskId,
    };
  }
}

// ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ Client ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬
class ClientContact {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String website;

  const ClientContact({required this.name, required this.email, required this.phone, this.address = '', this.website = ''});
}

class EcomSkuLog {
  final String id;
  final DateTime timestamp;
  final int sku;
  final int duplicate;
  final int catalogue;
  final String addedBy;

  EcomSkuLog({
    required this.id,
    required this.timestamp,
    required this.sku,
    required this.duplicate,
    required this.catalogue,
    required this.addedBy,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'sku': sku,
      'duplicate': duplicate,
      'catalogue': catalogue,
      'addedBy': addedBy,
    };
  }

  factory EcomSkuLog.fromFirestore(Map<String, dynamic> data) {
    return EcomSkuLog(
      id: data['id'] ?? '',
      timestamp: data['timestamp'] != null ? DateTime.parse(data['timestamp']) : DateTime.now(),
      sku: data['sku'] ?? 0,
      duplicate: data['duplicate'] ?? 0,
      catalogue: data['catalogue'] ?? 0,
      addedBy: data['addedBy'] ?? 'Unknown',
    );
  }
}

class ClientAddOn {
  String id;
  int month; // Deprecated
  int year; // Deprecated
  String type;
  double amount;
  String? description;
  bool isBilled;
  bool isPaid;
  DateTime dateAdded;

  ClientAddOn({
    required this.id,
    this.month = 1,
    this.year = 2026,
    required this.type,
    required this.amount,
    this.description,
    this.isBilled = false,
    this.isPaid = false,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'month': month,
    'year': year,
    'type': type,
    'amount': amount,
    'description': description,
    'isBilled': isBilled,
    'isPaid': isPaid,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory ClientAddOn.fromMap(Map<String, dynamic> map) => ClientAddOn(
    id: map['id'] ?? '',
    month: map['month'] ?? 1,
    year: map['year'] ?? 2026,
    type: map['type'] ?? 'Unknown',
    amount: (map['amount'] ?? 0).toDouble(),
    description: map['description'],
    isBilled: map['isBilled'] ?? false,
    isPaid: map['isPaid'] ?? false,
    dateAdded: map['dateAdded'] != null ? DateTime.parse(map['dateAdded']) : DateTime.now(),
  );
}

class Client {
  final String id;
  String name;
  ClientContact contact;
  String agreementTerms;
  String paymentTerms;
  double discountPercent;
  List<String> resourceLinks;
  String postRequirements;
  DateTime contractDate;
  String status;
  List<String> remarks;
  
  List<ClientAddOn> addOns;
  Map<String, double> monthlyDiscounts;
  bool isWebsiteHandlingActive;
  double websiteHandlingFee;


  // ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ New Package & Deliverables Fields ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬
  String packageType;       // 'Growth' or 'Performance'
  String contractPeriod;    // e.g. '3 Months', '6 Months', '1 Year'
  double monthlyPayable;    // base monthly fee in \u20B9
  int weeklyReels;
  int weeklyPosts;
  int weeklyCarousels;
  int weeklyStories;
  int campaigns;            // only for Performance package
  String campaignReach;     // only for Performance package, e.g. '50k-100k'

  int paymentsDue;

  // ---- Lead-specific fields ----
  List<String> followUpDates;    // e.g. ['2026-06-25', '2026-07-01']
  List<String> notes;            // comments/notes from meetings
  String conversionProbability;  // 'High', 'Medium', 'Low'

  // ---- Active client retention & payment health ----
  String retentionHealth;        // 'Great', 'Good', 'Bad'
  String nextDueDate;            // e.g. '5th of every month' or '2026-07-05'
  String paymentMode;            // 'Advance', 'Running', 'Late'
  int dueDateDay;                // 1-31
  bool isPaidForMonth;
  List<int> paidMonths;
  
  // ---- Videographer Link ----
  String? assignedVideographerId;
  double sessionRate;

  // ---- Graphics Editor Link ----
  String? assignedGraphicsEditorId;

  // ---- Marketing Executive Link & Splits ----
  String serviceType;             // 'Marketing', 'E-commerce', 'Video Production'
  bool hasMarketingCommission;    // true if ME gets 20%
  String? marketingExecutiveId;   // ID of ME
  String source;                  // 'my_lead', 'assigned', or 'general'
  bool isApprovedByCeo;           // false if ME converted it and CEO hasn't approved
  String? previousStatus;         // status to revert to if CEO rejects conversion
  String paidTill;                  // e.g. 'June 2026' - last month client payment was confirmed
  bool isTerminationRequested;      // true if ME requested termination
  String ecomPaymentType; // 'Monthly' or 'Per SKU'
  double clientSkuRate;
  double clientDuplicateSkuRate;
  double clientCatalogueRate;
  List<EcomSkuLog> ecomSkuLogs;

  double getPayableForMonth(int month, int year) {
    double total = monthlyPayable;
    if (serviceType.toLowerCase().contains('commerce') && ecomPaymentType == 'Per SKU') {
      total = 0;
      for (var log in ecomSkuLogs) {
        if (log.timestamp.month == month && log.timestamp.year == year) {
          total += (log.sku * clientSkuRate) + (log.duplicate * clientDuplicateSkuRate) + (log.catalogue * clientCatalogueRate);
        }
      }
    }
    if (isWebsiteHandlingActive) {
      total += websiteHandlingFee;
    }
    return total;
  }

  /// Computed: weeks since contractDate
  int get weeksActive {
    return DateTime.now().difference(contractDate).inDays ~/ 7;
  }

  /// Computed: List of pending month integers based on contractDate and current month
  List<int> get pendingMonths {
    List<int> pending = [];
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;
    
    int startMonth = 1;
    if (contractDate.year == currentYear) {
      startMonth = contractDate.month;
    } else if (contractDate.year > currentYear) {
      return pending;
    }
    
    for (int m = startMonth; m <= currentMonth; m++) {
      if (!paidMonths.contains(m)) {
        pending.add(m);
      }
    }
    return pending;
  }

  bool isMonthDue(int month) {
    int currentYear = DateTime.now().year;
    bool isBeforeJoinDate = false;
    if (contractDate.year == currentYear && month < contractDate.month) {
      isBeforeJoinDate = true;
    } else if (contractDate.year > currentYear) {
      isBeforeJoinDate = true;
    }
    if (isBeforeJoinDate) return false;
    if (paidMonths.contains(month)) return false;

    DateTime now = DateTime.now();
    DateTime dueDateForThisMonth;
    if (paymentMode == 'Late') {
      int dueMonth = month + 1;
      int dueYear = currentYear;
      if (dueMonth > 12) {
        dueMonth = 1;
        dueYear++;
      }
      dueDateForThisMonth = DateTime(dueYear, dueMonth, dueDateDay);
    } else {
      dueDateForThisMonth = DateTime(currentYear, month, dueDateDay);
    }

    return now.isAfter(dueDateForThisMonth) || now.isAtSameMomentAs(dueDateForThisMonth);
  }

  /// Computed: expected paid months based on paymentMode and dueDateDay
  double get totalAmountDue {
    double total = 0;
    int currentYear = DateTime.now().year;
    for (int i = 1; i <= 12; i++) {
      if (isMonthDue(i)) {
        total += getPayableForMonth(i, currentYear);
      }
    }
    return total;
  }

  int get dynamicPaymentsDue {
    int dueCount = 0;
    for (int i = 1; i <= 12; i++) {
      if (isMonthDue(i)) {
        dueCount++;
      }
    }
    return dueCount;
  }

  Client({
    required this.id,
    required this.name,
    required this.contact,
    this.agreementTerms = 'TBD',
    this.paymentTerms = 'TBD',
    this.discountPercent = 0,
    this.resourceLinks = const [],
    this.postRequirements = 'TBD',
    required this.contractDate,
    this.status = 'Lead',
    this.remarks = const [],
    this.packageType = 'Growth',
    this.contractPeriod = '3 Months',
    this.monthlyPayable = 0,
    this.weeklyReels = 0,
    this.weeklyPosts = 0,
    this.weeklyCarousels = 0,
    this.weeklyStories = 0,
    this.campaigns = 0,
    this.campaignReach = '',
    this.paymentsDue = 0,
    this.followUpDates = const [],
    this.notes = const [],
    this.conversionProbability = 'Medium',
    this.retentionHealth = 'Good',
    this.nextDueDate = 'TBD',
    this.paymentMode = 'Running',
    this.dueDateDay = 10,
    this.isPaidForMonth = false,
    this.paidMonths = const [],
    this.assignedVideographerId,
    this.assignedGraphicsEditorId,
    this.sessionRate = 0.0,
    this.serviceType = 'Marketing',
    this.hasMarketingCommission = false,
    this.marketingExecutiveId,
    this.source = 'general',
    this.isApprovedByCeo = true,
    this.previousStatus = 'Lead',
    this.paidTill = '',
    this.isTerminationRequested = false,
    this.ecomPaymentType = 'Monthly',
    this.clientSkuRate = 0.0,
    this.clientDuplicateSkuRate = 0.0,
    this.clientCatalogueRate = 0.0,
    this.ecomSkuLogs = const [],
    this.addOns = const [],
    this.monthlyDiscounts = const {},
    this.isWebsiteHandlingActive = false,
    this.websiteHandlingFee = 0.0,
  });

  factory Client.fromFirestore(Map<String, dynamic> data, String docId) {
    return Client(
      id: data['clientId'] ?? docId,
      name: data['name'] ?? '',
      contact: ClientContact(
        name: data['contactName'] ?? '',
        email: data['contactEmail'] ?? '',
        phone: data['contactPhone'] ?? '',
        address: data['contactAddress'] ?? '',
        website: data['contactWebsite'] ?? '',
      ),
      agreementTerms: data['agreementTerms'] ?? 'TBD',
      paymentTerms: data['paymentTerms'] ?? 'TBD',
      discountPercent: (data['discountPercent'] ?? 0).toDouble(),
      resourceLinks: List<String>.from(data['resourceLinks'] ?? []),
      postRequirements: data['postRequirements'] ?? 'TBD',
      contractDate: _parseDate(data['contractDate']),
      status: data['status'] ?? 'Lead',
      remarks: List<String>.from(data['remarks'] ?? []),
      packageType: data['packageType'] ?? 'Growth',
      contractPeriod: data['contractPeriod'] ?? '3 Months',
      monthlyPayable: (data['monthlyPayable'] ?? 0).toDouble(),
      weeklyReels: data['weeklyReels'] ?? 0,
      weeklyPosts: data['weeklyPosts'] ?? 0,
      weeklyCarousels: data['weeklyCarousels'] ?? 0,
      weeklyStories: data['weeklyStories'] ?? 0,
      campaigns: data['campaigns'] ?? 0,
      campaignReach: data['campaignReach'] ?? '',
      paymentsDue: data['paymentsDue'] ?? 0,
      followUpDates: List<String>.from(data['followUpDates'] ?? []),
      notes: List<String>.from(data['notes'] ?? []),
      conversionProbability: data['conversionProbability'] ?? 'Medium',
      retentionHealth: data['retentionHealth'] ?? 'Good',
      nextDueDate: data['nextDueDate'] ?? 'TBD',
      paymentMode: data['paymentMode'] ?? 'Running',
      dueDateDay: data['dueDateDay'] ?? 10,
      isPaidForMonth: data['isPaidForMonth'] ?? false,
      paidMonths: (data['paidMonths'] as List<dynamic>?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],
      assignedVideographerId: data['assignedVideographerId'],
      assignedGraphicsEditorId: data['assignedGraphicsEditorId'],
      sessionRate: (data['sessionRate'] ?? 0.0).toDouble(),
      serviceType: (data['serviceType'] ?? 'Marketing').toString().toLowerCase() == 'e-commerce' ? 'E-Commerce' : (data['serviceType'] ?? 'Marketing'),
      hasMarketingCommission: data['hasMarketingCommission'] ?? false,
      marketingExecutiveId: data['marketingExecutiveId'],
      source: data['source'] ?? 'general',
      isApprovedByCeo: data['isApprovedByCeo'] ?? true,
      previousStatus: data['previousStatus'] ?? 'Lead',
      paidTill: data['paidTill'] ?? '',
      isTerminationRequested: data['isTerminationRequested'] ?? false,
      ecomPaymentType: data['ecomPaymentType'] ?? 'Monthly',
      clientSkuRate: (data['clientSkuRate'] ?? 0.0).toDouble(),
      clientDuplicateSkuRate: (data['clientDuplicateSkuRate'] ?? 0.0).toDouble(),
      clientCatalogueRate: (data['clientCatalogueRate'] ?? 0.0).toDouble(),
      ecomSkuLogs: (data['ecomSkuLogs'] as List<dynamic>? ?? []).map((e) => EcomSkuLog.fromFirestore(e)).toList(),
      addOns: (data['addOns'] as List<dynamic>? ?? []).map((e) => ClientAddOn.fromMap(Map<String, dynamic>.from(e))).toList(),
      monthlyDiscounts: (data['monthlyDiscounts'] as Map<dynamic, dynamic>? ?? {}).map((key, value) => MapEntry(key.toString(), (value as num).toDouble())),
      isWebsiteHandlingActive: data['isWebsiteHandlingActive'] ?? false,
      websiteHandlingFee: (data['websiteHandlingFee'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'clientId': id,
    'name': name,
    'contactName': contact.name,
    'contactEmail': contact.email,
    'contactPhone': contact.phone,
    'contactAddress': contact.address,
    'contactWebsite': contact.website,
    'agreementTerms': agreementTerms,
    'paymentTerms': paymentTerms,
    'discountPercent': discountPercent,
    'resourceLinks': resourceLinks,
    'postRequirements': postRequirements,
    'contractDate': Timestamp.fromDate(contractDate),
    'status': status,
    'remarks': remarks,
    'packageType': packageType,
    'contractPeriod': contractPeriod,
    'monthlyPayable': monthlyPayable,
    'weeklyReels': weeklyReels,
    'weeklyPosts': weeklyPosts,
    'weeklyCarousels': weeklyCarousels,
    'weeklyStories': weeklyStories,
    'campaigns': campaigns,
    'campaignReach': campaignReach,
    'paymentsDue': paymentsDue,
    'followUpDates': followUpDates,
    'notes': notes,
    'conversionProbability': conversionProbability,
    'retentionHealth': retentionHealth,
    'nextDueDate': nextDueDate,
    'paymentMode': paymentMode,
    'dueDateDay': dueDateDay,
    'isPaidForMonth': isPaidForMonth,
    'paidMonths': paidMonths,
    if (assignedVideographerId != null) 'assignedVideographerId': assignedVideographerId,
    if (assignedGraphicsEditorId != null) 'assignedGraphicsEditorId': assignedGraphicsEditorId,
    'sessionRate': sessionRate,
    'serviceType': serviceType,
    'hasMarketingCommission': hasMarketingCommission,
    if (marketingExecutiveId != null) 'marketingExecutiveId': marketingExecutiveId,
    'source': source,
    'isApprovedByCeo': isApprovedByCeo,
    if (previousStatus != null) 'previousStatus': previousStatus,
    'paidTill': paidTill,
    'isTerminationRequested': isTerminationRequested,
    'ecomPaymentType': ecomPaymentType,
    'clientSkuRate': clientSkuRate,
    'clientDuplicateSkuRate': clientDuplicateSkuRate,
    'clientCatalogueRate': clientCatalogueRate,
    'ecomSkuLogs': ecomSkuLogs.map((e) => e.toFirestore()).toList(),
    'addOns': addOns.map((e) => e.toMap()).toList(),
    'monthlyDiscounts': monthlyDiscounts,
    'isWebsiteHandlingActive': isWebsiteHandlingActive,
    'websiteHandlingFee': websiteHandlingFee,
  };
}

// 
class FinanceEntry {
  final String id;
  final String label;
  final double amount;
  final bool isIncome; // false = expense
  final DateTime date;
  final String category;

  // Linked fields
  final String? incomeType;      // 'Monthly Payment' or 'Others'
  final String? expenseType;     // 'Salary' or 'Expense'
  final String? clientId;
  final String? employeeId;
  final String? paymentMonth;
  final int? sessionCount;
  final bool? isSessionBased;
  final bool isAdvance;
  final bool isLate;
  final String? paymentMethod; // e.g. Cash, UPI, Cheque
  final double discount;
  final String? serviceType;
  final String? marketingExecutiveId;

  const FinanceEntry({
    required this.id,
    required this.label,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.category,
    this.incomeType,
    this.expenseType,
    this.clientId,
    this.employeeId,
    this.paymentMonth,
    this.sessionCount,
    this.isSessionBased,
    this.isAdvance = false,
    this.isLate = false,
    this.paymentMethod,
    this.discount = 0.0,
    this.serviceType,
    this.marketingExecutiveId,
  });


  factory FinanceEntry.fromFirestore(Map<String, dynamic> data, String docId) {
    double parsedAmount = 0.0;
    if (data['amount'] is num) parsedAmount = (data['amount'] as num).toDouble();
    else if (data['amount'] is String) parsedAmount = double.tryParse(data['amount']) ?? 0.0;

    return FinanceEntry(
      id: docId,
      label: data['label'] ?? '',
      amount: parsedAmount,
      isIncome: data['isIncome'] ?? true,
      date: _parseDate(data['date']),
      category: data['category'] ?? 'General',
      incomeType: data['incomeType'],
      expenseType: data['expenseType'],
      clientId: data['clientId'],
      employeeId: data['employeeId'],
      paymentMonth: data['paymentMonth'],
      sessionCount: data['sessionCount'],
      isSessionBased: data['isSessionBased'],
      isAdvance: data['isAdvance'] ?? false,
      isLate: data['isLate'] ?? false,
      paymentMethod: data['paymentMethod'],
      discount: (data['discount'] ?? 0.0).toDouble(),
      serviceType: data['serviceType'],
      marketingExecutiveId: data['marketingExecutiveId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'amount': amount,
      'isIncome': isIncome,
      'date': Timestamp.fromDate(date),
      'category': category,
      if (incomeType != null) 'incomeType': incomeType,
      if (expenseType != null) 'expenseType': expenseType,
      if (clientId != null) 'clientId': clientId,
      if (employeeId != null) 'employeeId': employeeId,
      if (paymentMonth != null) 'paymentMonth': paymentMonth,
      if (sessionCount != null) 'sessionCount': sessionCount,
      if (isSessionBased != null) 'isSessionBased': isSessionBased,
      'isAdvance': isAdvance,
      'isLate': isLate,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      'discount': discount,
      if (serviceType != null) 'serviceType': serviceType,
      if (marketingExecutiveId != null) 'marketingExecutiveId': marketingExecutiveId,
    };
  }
}

extension StringEncodingFix on String {
  String get fixInr => this.replaceAll('Ã¢â€šÂ¹', '\u20B9');
}

class SageNotification {
  final String id;
  final String message;
  final String type;
  final DateTime timestamp;
  final String triggeredBy;
  bool isRead;

  SageNotification({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.triggeredBy,
    this.isRead = false,
  });

  factory SageNotification.fromFirestore(Map<String, dynamic> data, String docId) {
    return SageNotification(
      id: docId,
      message: data['message'] ?? '',
      type: data['type'] ?? 'info',
      timestamp: _parseDate(data['timestamp']),
      triggeredBy: data['triggeredBy'] ?? 'System',
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'triggeredBy': triggeredBy,
      'isRead': isRead,
    };
  }
}


