const fs=require('fs');
const p='C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/state/app_state.dart';
let t=fs.readFileSync(p,'utf8');
t = t.replace(`Map<String, String>? addEmployee({
    required String name,
    required String role,
    required String department,
    double monthlySalary = 0.0,
    double perSessionRate = 0.0,
    double perVideoRate = 0.0,
    int sessionsPerMonth = 0,
  }) {`, `Map<String, String>? addEmployee({
    required String name,
    required String role,
    required String department,
    double monthlySalary = 0.0,
    double perSessionRate = 0.0,
    double perVideoRate = 0.0,
    int sessionsPerMonth = 0,
    String preferredName = '',
  }) {`);
t = t.replace(`final emp = Employee(
      id: id,
      name: name,
      role: role,
      department: department,
      password: generatePassword(),
      monthlySalary: monthlySalary,
      perSessionRate: perSessionRate,
      perVideoRate: perVideoRate,
      sessionsPerMonth: sessionsPerMonth,
      joiningDate: DateTime.now(),
    );`, `final emp = Employee(
      id: id,
      name: name,
      preferredName: preferredName,
      role: role,
      department: department,
      password: generatePassword(),
      monthlySalary: monthlySalary,
      perSessionRate: perSessionRate,
      perVideoRate: perVideoRate,
      sessionsPerMonth: sessionsPerMonth,
      joiningDate: DateTime.now(),
    );`);
fs.writeFileSync(p,t);
console.log('Updated app_state.dart');
