// services/settings_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;

  SettingsService._internal() {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
  }

  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  final String _collectionName = 'user_settings';

  // Default settings
  final Map<String, dynamic> _defaultSettings = {
    'enableBiometrics': false,
    'autoSync': true,
    'backupEnabled': true,
    'autoLock': true,
    'cloudBackup': true,
  };

  // Load settings from local storage or Firebase
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      // Try to get current user
      final user = _auth.currentUser;

      if (user != null) {
        // Load from Firebase if user is authenticated
        return await _loadFromFirebase(user.uid);
      } else {
        // Load from local storage if not authenticated
        return await _loadFromLocalStorage();
      }
    } catch (e) {
      print('Error loading settings: $e');
      return _defaultSettings;
    }
  }

  // Save settings to appropriate storage
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await _saveToFirebase(user.uid, settings);
      }

      // Always save to local storage for offline access
      await _saveToLocalStorage(settings);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Firebase operations
  Future<Map<String, dynamic>> _loadFromFirebase(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return {..._defaultSettings, ...doc.data()!};
      } else {
        // Create default settings if they don't exist
        await _saveToFirebase(userId, _defaultSettings);
        return _defaultSettings;
      }
    } catch (e) {
      print('Firebase load error: $e');
      return await _loadFromLocalStorage();
    }
  }

  Future<void> _saveToFirebase(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .set(settings, SetOptions(merge: true));
    } catch (e) {
      print('Error saving to Firebase: $e');
    }
  }

  // Local storage operations
  Future<Map<String, dynamic>> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'enableBiometrics':
            prefs.getBool('enableBiometrics') ??
            _defaultSettings['enableBiometrics'],
        'autoSync': prefs.getBool('autoSync') ?? _defaultSettings['autoSync'],
        'backupEnabled':
            prefs.getBool('backupEnabled') ?? _defaultSettings['backupEnabled'],
        'autoLock': prefs.getBool('autoLock') ?? _defaultSettings['autoLock'],
        'cloudBackup':
            prefs.getBool('cloudBackup') ?? _defaultSettings['cloudBackup'],
      };
    } catch (e) {
      print('Error loading from local storage: $e');
      return _defaultSettings;
    }
  }

  Future<void> _saveToLocalStorage(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        'enableBiometrics',
        settings['enableBiometrics'] ?? false,
      );
      await prefs.setBool('autoSync', settings['autoSync'] ?? true);
      await prefs.setBool('backupEnabled', settings['backupEnabled'] ?? true);
      await prefs.setBool('autoLock', settings['autoLock'] ?? true);
      await prefs.setBool('cloudBackup', settings['cloudBackup'] ?? true);
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }

  // Clear settings on logout
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing settings: $e');
    }
  }
}
