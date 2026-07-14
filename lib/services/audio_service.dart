import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  
  static Future<void> playNotification(String type) async {
    try {
      if (type == 'task_assigned') {
        await _player.play(AssetSource('audio/new_task.mp3'));
      } else if (type == 'session_booked') {
        await _player.play(AssetSource('audio/new_session_booking.mp3'));
      } else {
        await _player.play(AssetSource('audio/general.mp3'));
      }
    } catch (e) {
      print('Audio playback failed: $e');
    }
  }
}
