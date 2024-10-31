import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'dart:typed_data';

class VoiceAuthentication {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  List<int> _userVoiceSample = [];
  List<int> _currentVoiceSample = [];
  StreamController<FoodData> _audioStreamController = StreamController<FoodData>();

  Future<void> initialize() async {
    await Permission.microphone.request();
    await _recorder.openAudioSession();
  }

  Future<void> startListeningForSample() async {
    _userVoiceSample.clear();
    _audioStreamController = StreamController<FoodData>();
    _audioStreamController.stream.listen((data) {
      if (data.data != null) {
        _userVoiceSample.addAll(data.data!);
        print("User voice sample recorded");
      }
    });
    await _recorder.startRecorder(
      toStream: _audioStreamController.sink,
    );
  }

  Future<void> stopListeningForSample() async {
    await _recorder.stopRecorder();
    await _audioStreamController.close();
    print("Listening stopped");
  }

  Future<void> startListeningForCommand() async {
    _currentVoiceSample.clear();
    _audioStreamController = StreamController<FoodData>();
    _audioStreamController.stream.listen((data) {
      if (data.data != null) {
        _currentVoiceSample.addAll(data.data!);
        print("Current voice sample recorded");
      }
    });
    await _recorder.startRecorder(
      toStream: _audioStreamController.sink,
    );
  }

  Future<void> stopListeningForCommand() async {
    await _recorder.stopRecorder();
    await _audioStreamController.close();
    print("Listening stopped");
  }

  Future<bool> authenticateVoice() async {
    bool value = _compareAudioSamples(_userVoiceSample, _currentVoiceSample);
    print("auth:   ---------$value");
    return _compareAudioSamples(_userVoiceSample, _currentVoiceSample);
  }

  bool _compareAudioSamples(List<int> sample1, List<int> sample2) {
    if (sample1.length != sample2.length) return false;
    for (int i = 0; i < sample1.length; i++) {
      if (sample1[i] != sample2[i]) return false;
    }
    return true;
  }

  List<int> get userVoiceSample => _userVoiceSample;
}