import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Initializing Firebase...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase Initialized!");

  final db = FirebaseFirestore.instance;

  // 4 tasks for Poulom
  for (int i = 1; i <= 4; i++) {
    await db.collection('tasks').add({
      'title': 'Session \$i (Restored)',
      'description': 'Recovered session from June.',
      'assignedTo': 'EMP-POU-001',
      'assignedBy': 'CEO-SOH-001',
      'deadline': Timestamp.fromDate(DateTime(2026, 6, 15)),
      'isCompleted': true,
      'isSubmitted': true,
      'createdAt': Timestamp.fromDate(DateTime(2026, 6, 10)),
      'completedAt': Timestamp.fromDate(DateTime(2026, 6, 15)),
      'submittedAt': Timestamp.fromDate(DateTime(2026, 6, 15)),
      'taskType': 'Session',
      'isApprovedByVideographer': true,
      'isPaidToVideographer': false,
      'isPaymentAcknowledgedByVideographer': false,
    });
  }
  print("Restored 4 session tasks for Poulom.");

  // 1 task for Soumyabrata
  await db.collection('tasks').add({
    'title': 'Video Editing Task (Restored)',
    'description': 'Recovered task from June.',
    'assignedTo': 'EMP-SOU-002',
    'assignedBy': 'CEO-SOH-001',
    'deadline': Timestamp.fromDate(DateTime(2026, 6, 20)),
    'isCompleted': true,
    'isSubmitted': true,
    'createdAt': Timestamp.fromDate(DateTime(2026, 6, 15)),
    'completedAt': Timestamp.fromDate(DateTime(2026, 6, 20)),
    'submittedAt': Timestamp.fromDate(DateTime(2026, 6, 20)),
    'taskType': 'Task',
    'isApprovedByVideographer': true,
    'isPaidToVideographer': false,
    'isPaymentAcknowledgedByVideographer': false,
  });
  print("Restored 1 task for Soumyabrata.");

  print("DONE.");
  exit(0);
}
