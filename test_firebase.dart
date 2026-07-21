import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  try {
    print("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized!");

    print("Attempting to read tasks collection...");
    final query = await FirebaseFirestore.instance.collection('tasks').get();
    print("Read successful! Found ${query.docs.length} tasks.");

    print("Attempting to write a test task...");
    final ref = await FirebaseFirestore.instance.collection('tasks').add({
      'title': 'Test Task',
      'description': 'Test',
      'assignedTo': 'SELF',
      'assignedBy': 'SYSTEM',
      'deadline': Timestamp.now(),
      'isCompleted': false,
      'createdAt': Timestamp.now(),
    });
    print("Write successful! Document ID: ${ref.id}");

    exit(0);
  } catch (e, stack) {
    print("ERROR OCCURRED:");
    print(e);
    print(stack);
    exit(1);
  }
}
