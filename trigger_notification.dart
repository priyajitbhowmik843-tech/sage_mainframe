import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'lib/services/fcm_config.dart';

Future<void> main() async {
  final accountCredentials = ServiceAccountCredentials.fromJson(FcmConfig.serviceAccountJson);
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging', 'https://www.googleapis.com/auth/datastore'];
  final authClient = await clientViaServiceAccount(accountCredentials, scopes);
  
  final String projectId = 'sageosf-cf0dc';
  final firestoreUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/fcm_tokens';
  
  final res = await authClient.get(Uri.parse(firestoreUrl));
  final Map<String, dynamic> data = json.decode(res.body);
  
  if (data['documents'] == null) {
    print('No FCM tokens found in the database. Please open the app first.');
    authClient.close();
    return;
  }
  
  final tokenList = (data['documents'] as List).map((doc) => doc['fields']['token']['stringValue']).toList();
  
  final fcmUrl = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
  
  for (var token in tokenList) {
    final payload = {
      'message': {
        'token': token,
        'notification': {
          'title': 'General Alert',
          'body': 'This is a general notification test! Did the sound play?',
        },
        'android': {
          'notification': {
            'channel_id': 'sage_general_channel_v2',
            'sound': 'general'
          }
        }
      }
    };
    
    final pushRes = await authClient.post(
      Uri.parse(fcmUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload)
    );
    print('Sent to token ending in ...${token.toString().substring(token.toString().length - 10)}');
    print('Response: ${pushRes.statusCode} ${pushRes.body}');
  }
  authClient.close();
}
