import 'lib/models/models.dart';
void main() {
  try {
    final emp = Employee.fromFirestore({}, 'doc123');
    print("Success: ${emp.name}");
  } catch (e, stack) {
    print("Error: $e");
    print(stack);
  }
}
