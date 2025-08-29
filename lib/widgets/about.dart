import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("About DeepNotes"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon/Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.note_alt_rounded,
                size: 40,
                color: colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              "DeepNotes",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              "Smart Notes with AI Integration",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Description
            Text(
              "DeepNotes is an intelligent note-taking app designed to enhance your productivity. "
              "Heavily inspired by Google Keep Notes, it combines simplicity with powerful features "
              "and will soon integrate AI capabilities to revolutionize how you capture and organize ideas.",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Features List
            _buildFeatureSection(theme, colorScheme),

            const SizedBox(height: 32),

            // Version Info (Static version)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Version",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text("1.0.0 (build 1)", style: theme.textTheme.bodyMedium),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Links
            _buildLinksSection(theme, colorScheme),

            const SizedBox(height: 24),

            // Copyright
            Text(
              "© 2025 DeepNotes. All rights reserved.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(ThemeData theme, ColorScheme colorScheme) {
    final features = [
      "Clean, intuitive interface",
      "Smart organization with tags and categories",
      "AI-powered suggestions (coming soon)",
      "Cross-platform synchronization",
      "Advanced search capabilities",
      "Customizable themes",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Features",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Column(
          children: features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(feature, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLinksSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Privacy Policy
        ListTile(
          leading: Icon(Icons.privacy_tip, color: colorScheme.primary),
          title: const Text("Privacy Policy"),
          onTap: () => _launchURL('https://example.com/privacy'),
          contentPadding: EdgeInsets.zero,
        ),

        // Terms of Service
        ListTile(
          leading: Icon(Icons.description, color: colorScheme.primary),
          title: const Text("Terms of Service"),
          onTap: () => _launchURL('https://example.com/terms'),
          contentPadding: EdgeInsets.zero,
        ),

        // Contact Support
        ListTile(
          leading: Icon(Icons.support_agent, color: colorScheme.primary),
          title: const Text("Contact Support"),
          onTap: () => _launchURL('mailto:support@deepnotes.com'),
          contentPadding: EdgeInsets.zero,
        ),

        // GitHub Repository
        ListTile(
          leading: Icon(Icons.code, color: colorScheme.primary),
          title: const Text("GitHub Repository"),
          onTap: () => _launchURL('https://github.com/yourusername/deepnotes'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
