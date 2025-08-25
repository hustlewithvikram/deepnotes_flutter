import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/google_one_tap.dart';
import 'settings.dart';
import 'about.dart';

class AccountSheet {
  static void show(BuildContext context, ThemeMode themeMode, ValueChanged<ThemeMode> onThemeChanged) {
    final authService = AuthService();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = themeMode == ThemeMode.dark;
        final user = FirebaseAuth.instance.currentUser;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user == null)
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text("Sign in with Google"),
                  onTap: () async {
                    Navigator.pop(context);
                    await authService.signInWithOneTap();
                  },
                )
              else ...[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(user.displayName ?? "No name"),
                  subtitle: Text(user.email ?? "No email"),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Sign out"),
                  onTap: () async {
                    Navigator.pop(context);
                    await authService.signOut();
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Settings()),
                  );
                },
              ),
              SwitchListTile(
                value: isDark,
                onChanged: (val) => onThemeChanged(val ? ThemeMode.dark : ThemeMode.light),
                title: const Text("Dark Mode"),
                secondary: const Icon(Icons.dark_mode),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("About"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const About()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
