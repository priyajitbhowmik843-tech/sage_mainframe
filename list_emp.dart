import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sage_mainframe/firebase_options.dart';
import 'dart:io';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final db = FirebaseFirestore.instance;
  
  final snapshot = await db.collection('employees').get();
  for (var doc in snapshot.docs) {
    print("${doc.id} : ${doc.data()['name']} - ${doc.data()['role']}");
  }
  exit(0);
}
