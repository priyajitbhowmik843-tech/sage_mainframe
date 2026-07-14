import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Starting override script...");

  final firestore = FirebaseFirestore.instance;

  final snapshot = await firestore.collection('employees').get();
  for (var doc in snapshot.docs) {
    final data = doc.data();
    final name = (data['name'] as String?)?.toLowerCase() ?? '';
    
    if (name.contains('debjit')) {
      print("Found Debjit: ${doc.id}");
      await doc.reference.update({
        'paidMonths': ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
        'paymentMode': 'Late',
        'pendingPayMonth': FieldValue.delete(),
        'pendingPayAmount': 0.0,
      });
      print("Updated Debjit.");
    }
    
    if (name.contains('soumyabrata')) {
      print("Found Soumyabrata: ${doc.id}");
      await doc.reference.update({
        'paidMonths': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        'paymentMode': 'Running',
        'pendingPayMonth': FieldValue.delete(),
        'pendingPayAmount': 0.0,
      });
      print("Updated Soumyabrata.");
    }
  }

  print("Override complete.");
}
