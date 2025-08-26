// home_page.dart
import 'package:deepnotes_flutter/widgets/notes_grid.dart';
import 'package:deepnotes_flutter/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:deepnotes_flutter/database/app_database.dart';
import 'package:deepnotes_flutter/database/models/note.dart';
import 'note_editor.dart';
import 'account_sheet.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const HomePage({super.key, required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Note> _notes = [];
  final Set<int> _selectedNoteIds = {};

  bool get isSelectionMode => _selectedNoteIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final allNotes = await AppDatabase.instance.getAllNotes();
    setState(() => _notes = allNotes);
  }

  Future<void> _openNoteEditor([Note? note]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => NoteEditor(note: note)),
    );
    if (changed == true) _loadNotes();
  }

  void _confirmDeleteSelected() async {
    if (_selectedNoteIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_selectedNoteIds.length} note(s)?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in _selectedNoteIds) {
        await AppDatabase.instance.deleteNote(id);
      }
      setState(() {
        _selectedNoteIds.clear();
      });
      _loadNotes();
    }
  }

  /// Pin all selected notes
  Future<void> _pinSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      final note = _notes.firstWhere((n) => n.id == id);
      if (!note.isPinned) {
        final updatedNote = Note(
          id: note.id,
          title: note.title,
          description: note.description,
          createdAt: note.createdAt,
          isPinned: true, // updated here
        );
        await AppDatabase.instance.updateNote(updatedNote);
      }
    }
    _selectedNoteIds.clear();
    _loadNotes();
  }

  /// Unpin all selected notes
  Future<void> _unpinSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      final note = _notes.firstWhere((n) => n.id == id);
      if (note.isPinned) {
        final updatedNote = Note(
          id: note.id,
          title: note.title,
          description: note.description,
          createdAt: note.createdAt,
          isPinned: false, // updated here
        );
        await AppDatabase.instance.updateNote(updatedNote);
      }
    }
    _selectedNoteIds.clear();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _searchFocusNode.hasFocus;
    final hasText = _searchController.text.isNotEmpty;

    final filteredNotes = hasText
        ? _notes.where((n) {
            final q = _searchController.text.toLowerCase();
            return n.title.toLowerCase().contains(q) ||
                n.description.toLowerCase().contains(q);
          }).toList()
        : _notes;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(), // ✅ unfocus anywhere
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              // ✅ SearchBarWidget (from search_bar.dart)
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  return SearchBarWidget(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    isSelectionMode: isSelectionMode,
                    hasFocus: hasFocus,
                    hasText: hasText,
                    user: snapshot.data,
                    onClear: () {
                      setState(() {
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      });
                    },
                    onDelete: _confirmDeleteSelected,
                    onPin: _pinSelectedNotes,
                    onUnpin: _unpinSelectedNotes,
                    onAccountTap: () =>
                        AccountSheet.show(context, widget.onThemeChanged),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ✅ NotesGrid (from notes_grid.dart)
              Expanded(
                child: filteredNotes.isEmpty
                    ? const Center(child: Text('No notes yet.'))
                    : NotesGrid(
                        notes: filteredNotes,
                        selectedNoteIds: _selectedNoteIds,
                        onTap: (note) => _openNoteEditor(note),
                        onLongPress: (note) {
                          setState(() {
                            if (_selectedNoteIds.contains(note.id)) {
                              _selectedNoteIds.remove(note.id);
                            } else {
                              _selectedNoteIds.add(note.id!);
                            }
                          });
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // ✅ FAB for adding notes
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("New Note"),
        onPressed: () => _openNoteEditor(),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
