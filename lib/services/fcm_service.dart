import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fcm_config.dart';
import 'dart:async';

class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _firestore = FirebaseFirestore.instance;
  static StreamSubscription<String>? _tokenRefreshSub;

  /// Requests notification permissions and saves the FCM device token
  /// to the Firestore cm_tokens collection under the active persona's ID.
  static Future<void> initializeAndSaveToken(String personaId) async {
    try {
      NotificationSettings settings = await _messaging.requestPermission();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _messaging.getToken();
        
        if (token != null) {
          await _firestore.collection('fcm_tokens').doc(personaId).set({
            'token': token,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('FCM Token saved for $personaId');
        }
        
        // Listen for token refreshes
        await _tokenRefreshSub?.cancel();
        _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
           _firestore.collection('fcm_tokens').doc(personaId).set({
            'token': newToken,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
      }
    } catch (e) {
      print('FCM Initialization error: $e');
    }
  }

  /// Sends a push notification directly from this client to another user
  /// by looking up their FCM token in Firestore.
  /// NOTE: Disabled temporarily for Web compatibility. Use Cloud Functions instead.
  static Future<void> sendNotification({
    required String targetPersonaId,
    required String title,
    required String body,
  }) async {
    print('FCM sendNotification disabled to prevent Web crash.');
  }
}
