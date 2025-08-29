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
  bool get hasFocus => _searchFocusNode.hasFocus;
  bool get hasText => _searchController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    _loadNotes();
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (isSelectionMode) {
      // Clear selection first and trigger UI update
      _clearSelection();
      return false; // Don't exit app
    }
    return true; // Exit app
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
    if (changed == true) await _loadNotes();
  }

  void _toggleNoteSelection(Note note) {
    setState(() {
      if (_selectedNoteIds.contains(note.id)) {
        _selectedNoteIds.remove(note.id);
      } else {
        _selectedNoteIds.add(note.id!);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteIds.clear();
      print("Selection cleared: $_selectedNoteIds"); // Debug print
    });
  }

  /// Pin all selected notes
  Future<void> _pinSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      final note = _notes.firstWhere((n) => n.id == id);
      if (!note.isPinned) {
        final updatedNote = note.copyWith(isPinned: true);
        await AppDatabase.instance.updateNote(updatedNote);
      }
    }
    _clearSelection();
    await _loadNotes();
  }

  /// Unpin all selected notes
  Future<void> _unpinSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      final note = _notes.firstWhere((n) => n.id == id);
      if (note.isPinned) {
        final updatedNote = note.copyWith(isPinned: false);
        await AppDatabase.instance.updateNote(updatedNote);
      }
    }
    _clearSelection();
    await _loadNotes();
  }

  /// Delete all selected notes
  Future<void> _deleteSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      await AppDatabase.instance.deleteNote(id);
    }
    _clearSelection();
    await _loadNotes();
  }

  void _handleSearchClear() {
    setState(() {
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
  }

  List<Note> get _filteredNotes {
    if (!hasText) return _notes;

    final query = _searchController.text.toLowerCase();
    return _notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(query) ||
              note.description.toLowerCase().contains(query),
        )
        .toList();
  }

  bool get _allSelectedPinned {
    if (_selectedNoteIds.isEmpty) return false;
    return _selectedNoteIds.every((id) {
      final note = _notes.firstWhere(
        (n) => n.id == id,
        orElse: () => _createEmptyNote(),
      );
      return note.isPinned;
    });
  }

  bool get _allSelectedUnpinned {
    if (_selectedNoteIds.isEmpty) return false;
    return _selectedNoteIds.every((id) {
      final note = _notes.firstWhere(
        (n) => n.id == id,
        orElse: () => _createEmptyNote(),
      );
      return !note.isPinned;
    });
  }

  // Helper method to create an empty note for fallback
  Note _createEmptyNote() {
    return Note(
      id: -1,
      title: '',
      description: '',
      createdAt: DateTime.now(),
      isPinned: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // Also clear selection when tapping outside
            if (isSelectionMode) {
              _clearSelection();
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    final user = snapshot.data;

                    return SearchBarWidget(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      isSelectionMode: isSelectionMode,
                      hasFocus: hasFocus,
                      hasText: hasText,
                      user: user,
                      selectedCount: _selectedNoteIds.length,
                      allSelectedPinned: _allSelectedPinned,
                      allSelectedUnpinned: _allSelectedUnpinned,
                      onClear: _handleSearchClear,
                      onDelete: _deleteSelectedNotes,
                      onPin: _pinSelectedNotes,
                      onUnpin: _unpinSelectedNotes,
                      onAccountTap: () =>
                          AccountSheet.show(context, widget.onThemeChanged),
                      onSearchChanged: (query) {
                        setState(() {}); // Trigger rebuild on search
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: _filteredNotes.isEmpty
                      ? _buildEmptyState()
                      : NotesGrid(
                          notes: _filteredNotes,
                          selectedNoteIds: _selectedNoteIds,
                          onTap: (note) => isSelectionMode
                              ? _toggleNoteSelection(note)
                              : _openNoteEditor(note),
                          onLongPress: (note) => _toggleNoteSelection(note),
                        ),
                ),
              ],
            ),
          ),
        ),

        floatingActionButton: FloatingActionButton.extended(
          label: const Text("New Note"),
          onPressed: () => _openNoteEditor(),
          icon: const Icon(Icons.add),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasText ? Icons.search_off : Icons.note_add,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasText ? 'No notes found' : 'No notes yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          if (!hasText) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _openNoteEditor(),
              child: const Text('Create your first note'),
            ),
          ],
        ],
      ),
    );
  }
}
