import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instance;
  final snap = await db.collection('employees').get();

  for (var doc in snap.docs) {
    final data = doc.data();
    final name = data['name'] as String? ?? '';
    final paid =
        (data['paidMonths'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    print('Employee: $name, PaidMonths: $paid');

    if (name.toUpperCase().contains('DEBJIT')) {
      print('Found Debjit! Fixing...');
      await doc.reference.update({
        'paidMonths': ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
      });
      print('Debjit fixed.');
    }
  }
}
