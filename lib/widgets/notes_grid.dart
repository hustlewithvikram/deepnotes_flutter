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

    // Separate pinned and unpinned notes
    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Pinned Notes Section
        if (pinnedNotes.isNotEmpty) ...[
          _buildSectionHeader('Pinned'),
          const SizedBox(height: 2), // Reduced even more
          _buildNotesGrid(pinnedNotes, isSelectionMode),
        ],

        // Add spacing between sections only if both exist
        if (pinnedNotes.isNotEmpty && unpinnedNotes.isNotEmpty)
          const SizedBox(height: 12), // Reduced from 16
        // Other Notes Section
        if (unpinnedNotes.isNotEmpty) ...[
          if (pinnedNotes.isNotEmpty) _buildSectionHeader('Others'),
          if (pinnedNotes.isNotEmpty) const SizedBox(height: 2), // Reduced
          _buildNotesGrid(unpinnedNotes, isSelectionMode),
        ],

        // Empty state if no notes
        if (notes.isEmpty) _buildEmptyState(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNotesGrid(List<Note> notes, bool isSelectionMode) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero, // ← THIS IS THE KEY FIX!
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8, // Reduced from 12
        mainAxisSpacing: 8, // Reduced from 12
        childAspectRatio: 0.9,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = selectedNoteIds.contains(note.id);

        return NoteTile(
          note: note,
          isSelected: isSelected,
          isSelectionMode: isSelectionMode,
          onTap: () {
            if (isSelectionMode) {
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
