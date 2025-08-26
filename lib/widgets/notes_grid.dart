import 'package:flutter/material.dart';
import 'package:deepnotes_flutter/database/models/note.dart';
import 'note_tile.dart';

class NotesGrid extends StatelessWidget {
  final List<Note> notes;
  final Set<int> selectedNoteIds;
  final void Function(Note note) onTap;
  final void Function(Note note) onLongPress;

  const NotesGrid({
    super.key,
    required this.notes,
    required this.selectedNoteIds,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = selectedNoteIds.isNotEmpty;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = selectedNoteIds.contains(note.id);

        return NoteTile(
          note: note,
          isSelected: isSelected,
          onTap: () {
            if (isSelectionMode) {
              // Toggle selection instead of opening editor
              onLongPress(note);
            } else {
              onTap(note);
            }
          },
          onLongPress: () => onLongPress(note),
        );
      },
    );
  }
}
