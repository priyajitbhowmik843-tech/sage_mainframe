import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  try {
    print("Initializing Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase Initialized!");

    // Find Soumyabrata
    final emps = await FirebaseFirestore.instance.collection('employees').get();
    String soumyaId = '';
    for (var doc in emps.docs) {
      if (doc.data()['name'].toString().toLowerCase().contains('soumya')) {
        soumyaId = doc.id;
        print("Found Soumyabrata! ID: $soumyaId");
        break;
      }
    }

    if (soumyaId.isEmpty) {
      print("Could not find Soumyabrata!");
      exit(1);
    }

    // Find all 'Session' tasks assigned to him
    final tasks = await FirebaseFirestore.instance.collection('tasks').where('assignedTo', isEqualTo: soumyaId).get();
    
    int deletedCount = 0;
    for (var doc in tasks.docs) {
      if (doc.data()['taskType'] == 'Session') {
        print("Deleting Session Task: ${doc.id}");
        await doc.reference.delete();
        deletedCount++;
      }
    }

    print("Deleted $deletedCount session tasks for Soumyabrata.");
    exit(0);
  } catch (e) {
    print("Error: $e");
    exit(1);
  }
}
