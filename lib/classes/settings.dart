import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Settings {
  bool isVoiceRecognition = false;
  bool isLocationPermission = false;
  bool isRecordingPermission = false;
  bool viaWhatsApp = false;
  bool viaSMS = false;
  bool viaTelegram = false;
  bool viaAPP = false;
  String voiceCmdActivate="";
  String voiceCmdCancel="";
  List<int> userVoiceSample = [];

  // Secure Storage instance
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Function to read settings from secure storage
  Future<void> loadSettings() async {
    isVoiceRecognition = (await secureStorage.read(key: 'isVoiceRecognition')) == 'true';
    isLocationPermission = (await secureStorage.read(key: 'isLocationPermission')) == 'true';
    isRecordingPermission = (await secureStorage.read(key: 'isRecordingPermission')) == 'true';
    viaWhatsApp = (await secureStorage.read(key: 'viaWhatsApp')) == 'true';
    viaSMS = (await secureStorage.read(key: 'viaSMS')) == 'true';
    viaTelegram = (await secureStorage.read(key: 'viaTelegram')) == 'true';
    viaAPP = (await secureStorage.read(key: 'viaAPP')) == 'true';
  }

  // Function to update and save the location permission setting
  Future<void> setUserVoiceSample(List<int> value) async {
    await secureStorage.write(key: 'userVoiceSample', value: '$value');
    userVoiceSample = value;
    print("isLocationPermission after update: $userVoiceSample");
  }
  // Function to update and save the location permission setting
  Future<void> setIsLocationPermission(bool value) async {
    await secureStorage.write(key: 'isLocationPermission', value: '$value');
    isLocationPermission = value;
    print("isLocationPermission after update: $isLocationPermission");
  }

  // Function to update and save the location permission setting
  Future<void> setVoiceCmdActivate(String value) async {
    await secureStorage.write(key: 'voiceCmdActivate', value: '$value');
    voiceCmdActivate = value;
    print("Voice command: $voiceCmdActivate");
  }
  // Function to update and save the location permission setting
  Future<void> setVoiceCmdCancel(String value) async {
    await secureStorage.write(key: 'voiceCmdCancel', value: '$value');
    voiceCmdCancel = value;
    print("Voice command: $voiceCmdCancel");
  }


  // Similar functions can be added for other settings
  Future<void> setIsVoiceRecognition(bool value) async {
    await secureStorage.write(key: 'isVoiceRecognition', value: '$value');
    isVoiceRecognition = value;
    print("isVoiceRecognition after update: $isVoiceRecognition");
  }
  Future<void> setViaWhatsApp(bool value) async {
    await secureStorage.write(key: 'viaWhatsApp', value: '$value');
    viaWhatsApp = value;
    print("is via whatsapp after update: $viaWhatsApp");
  }
  Future<void> setViaSMS(bool value) async {
    await secureStorage.write(key: 'viaSMS', value: '$value');
    viaSMS = value;
    print("is via SMS after update: $viaSMS");
  }
  Future<void> setViaTelegram(bool value) async {
    await secureStorage.write(key: 'viaTelegram', value: '$value');
    viaTelegram = value;
    print("is via telegram after update: $viaTelegram");
  }
  Future<void> setViaAPP(bool value) async {
    await secureStorage.write(key: 'viaAPP', value: '$value');
    viaAPP = value;
    print("is via app after update: $viaAPP");
  }

  Future<void> setIsRecordingPermission(bool value) async {
    print("isRecordingPermission before update: $isRecordingPermission");
    final location =secureStorage.read(key: 'isRecordingPermission');
    print("isRecordingPermission secure storage before update: $location");
    await secureStorage.write(key: 'isRecordingPermission', value: '$value');
    final location1 =secureStorage.read(key: 'isRecordingPermission');
    print("isRecordingPermission secure storage after update: $location1");
    isRecordingPermission = value;
    print("isRecordingPermission after update: $isRecordingPermission");
  }

// Add methods for other settings similarly...
// GET methods -----------------------------------------
// Function to update and save the location permission setting
  Future<String?> getVoiceCmdActivate() async {
    final value = await secureStorage.read(key: 'voiceCmdActivate');
    return value; // Return the value of type String? (which can be null)
  }
  Future<String?> getVoiceCmdCancel() async {
    final value = await secureStorage.read(key: 'voiceCmdCancel');
    return value; // Return the value of type String? (which can be null)
  }


}
