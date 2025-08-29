import 'package:flutter/material.dart';
import 'package:deepnotes_flutter/database/models/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteTile({
    super.key,
    required this.note,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate content height based on text length
    final hasContent = note.title.isNotEmpty || note.description.isNotEmpty;
    final titleLines = note.title.isEmpty ? 0 : 1;
    final descriptionLines = _calculateDescriptionLines(note.description);

    // Determine total lines (min 2, max 8)
    final totalLines = (titleLines + descriptionLines).clamp(2, 8);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 80, // Minimum height
          maxHeight: 200, // Maximum height
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color.fromARGB(255, 219, 219, 219)),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Main note content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (note.title.isNotEmpty)
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  if (note.title.isNotEmpty && note.description.isNotEmpty)
                    const SizedBox(height: 6),

                  if (note.description.isNotEmpty)
                    Expanded(
                      child: Text(
                        note.description,
                        maxLines: totalLines - (note.title.isNotEmpty ? 1 : 0),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),

                  // Show empty state if no content
                  if (!hasContent)
                    Text(
                      'Empty note...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // Check icon for selection mode
            if (isSelectionMode)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey[500]!,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),

            // Pin indicator - uncomment if you need it
            // if (note.isPinned)
            //   Positioned(
            //     top: 4,
            //     left: 4,
            //     child: Container(
            //       padding: const EdgeInsets.all(3),
            //       decoration: BoxDecoration(
            //         color: theme.cardColor.withOpacity(0.9),
            //         shape: BoxShape.circle,
            //       ),
            //       child: Icon(
            //         Icons.push_pin,
            //         size: 12,
            //         color: theme.colorScheme.primary,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  // Calculate appropriate number of lines for description
  int _calculateDescriptionLines(String description) {
    if (description.isEmpty) return 0;

    // Count line breaks and estimate content density
    final lineBreaks = '\n'.allMatches(description).length;
    final wordCount = description
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    final charCount = description.length;

    // Simple heuristic to determine appropriate line count
    if (charCount < 50) return 1;
    if (charCount < 100) return 2;
    if (charCount < 200) return 3;
    if (charCount < 300) return 4;
    if (charCount < 400) return 5;
    return 6; // Max lines for description
  }
}
