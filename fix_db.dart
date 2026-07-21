import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sage_mainframe/firebase_options.dart';
import 'dart:io';

void main() async {
  print("Initializing Firebase...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final db = FirebaseFirestore.instance;

  print("Fixing notifications...");
  final notifs = await db.collection('notifications').get();
  int count = 0;
  for (var doc in notifs.docs) {
    String message = doc.data()['message'] ?? '';
    if (message.contains('â‚¹')) {
      await db.collection('notifications').doc(doc.id).update({
        'message': message.replaceAll('â‚¹', '\u20B9'),
      });
      count++;
    }
  }
  print("Fixed \$count notifications.");

  print("Fixing archived notifications...");
  final archNotifs = await db.collection('archived_notifications').get();
  int archCount = 0;
  for (var doc in archNotifs.docs) {
    String message = doc.data()['message'] ?? '';
    if (message.contains('â‚¹')) {
      await db.collection('archived_notifications').doc(doc.id).update({
        'message': message.replaceAll('â‚¹', '\u20B9'),
      });
      archCount++;
    }
  }
  print("Fixed \$archCount archived notifications.");

  print("Fixing active finances (label)...");
  final fin = await db.collection('finances').get();
  int finCount = 0;
  for (var doc in fin.docs) {
    String label = doc.data()['label'] ?? '';
    if (label.contains('â‚¹')) {
      await db.collection('finances').doc(doc.id).update({
        'label': label.replaceAll('â‚¹', '\u20B9'),
      });
      finCount++;
    }
  }
  print("Fixed \$finCount active finances.");

  print("Fixing archived finances (label)...");
  final archFin = await db.collection('archived_finances').get();
  int archFinCount = 0;
  for (var doc in archFin.docs) {
    String label = doc.data()['label'] ?? '';
    if (label.contains('â‚¹')) {
      await db.collection('archived_finances').doc(doc.id).update({
        'label': label.replaceAll('â‚¹', '\u20B9'),
      });
      archFinCount++;
    }
  }
  print("Fixed \$archFinCount archived finances.");

  print("Done! Exiting.");
  exit(0);
}
