import 'package:deepnotes_flutter/home.dart';
import 'package:deepnotes_flutter/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize preferences before app start
  await PreferenceUtils.init();

  runApp(const Home());
}
