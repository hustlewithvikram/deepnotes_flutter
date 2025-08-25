import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:deepnotes_flutter/database/app_database.dart';
import 'package:deepnotes_flutter/database/models/note.dart';
import 'note_editor.dart';
import 'account_sheet.dart';

class HomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomePage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Note> _notes = [];
  Set<int> _selectedNoteIds = {}; // selection tracked by ID

  bool get isSelectionMode => _selectedNoteIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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

    if (changed == true) {
      _loadNotes();
    }
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white), // text color
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              textStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final noteId in _selectedNoteIds) {
        await AppDatabase.instance.deleteNote(noteId);
      }
      _selectedNoteIds.clear();
      _loadNotes();
    }
  }

  Future<bool> _onWillPop() async {
    if (isSelectionMode) {
      setState(() => _selectedNoteIds.clear());
      return false; // prevent exiting
    }
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
      return false; // prevent exiting
    }
    return true; // default back behavior
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFocus = _searchFocusNode.hasFocus;
    final hasText = _searchController.text.isNotEmpty;
    final user = FirebaseAuth.instance.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final filteredNotes = hasText
        ? _notes.where((note) {
            final query = _searchController.text.toLowerCase();
            return note.title.toLowerCase().contains(query) ||
                note.description.toLowerCase().contains(query);
          }).toList()
        : _notes;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: "Search Notes",
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.search),
                    ),
                    elevation: WidgetStateProperty.all(0),
                    trailing: [
                      if (isSelectionMode)
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: theme.colorScheme.error,
                            size: 28,
                          ),
                          splashRadius: 20,
                          onPressed: _confirmDeleteSelected,
                        )
                      else if (hasFocus || hasText)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 28),
                          splashRadius: 20,
                          onPressed: () {
                            if (_searchController.text.isEmpty) {
                              _searchFocusNode.unfocus();
                            } else {
                              _searchController.clear();
                            }
                            setState(() {});
                          },
                        )
                      else
                        GestureDetector(
                          onTap: () => AccountSheet.show(
                            context,
                            widget.themeMode,
                            widget.onThemeChanged,
                          ),
                          child: user != null
                              ? CircleAvatar(
                                  backgroundImage: user.photoURL != null
                                      ? NetworkImage(user.photoURL!)
                                      : null,
                                  child: user.photoURL == null
                                      ? const Icon(Icons.person)
                                      : null,
                                )
                              : const Icon(Icons.account_circle, size: 28),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredNotes.isEmpty
                      ? const Center(child: Text('No notes yet.'))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 8,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 3 / 2,
                              ),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            final isSelected =
                                note.id != null &&
                                _selectedNoteIds.contains(note.id);
                            final bgColor = isSelected
                                ? Colors.blue.withOpacity(0.4)
                                : theme.colorScheme.primary.withOpacity(0.1);
                            return GestureDetector(
                              onTap: () {
                                if (isSelectionMode) {
                                  if (note.id != null) {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedNoteIds.remove(note.id);
                                      } else {
                                        _selectedNoteIds.add(note.id!);
                                      }
                                    });
                                  }
                                } else {
                                  _openNoteEditor(note);
                                }
                              },
                              onLongPress: () {
                                if (note.id != null) {
                                  setState(
                                    () => _selectedNoteIds.add(note.id!),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.white70,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (note.isPinned)
                                      const Align(
                                        alignment: Alignment.topRight,
                                        child: Icon(Icons.push_pin, size: 18),
                                      ),
                                    Text(
                                      note.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // Use Expanded to make description fill remaining space
                                    Expanded(
                                      child: Text(
                                        note.description,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("New Note"),
          onPressed: () => _openNoteEditor(),
          tooltip: 'New Note',
          icon: const Icon(Icons.add),
          elevation: 0,
        ),
      ),
    );
  }
}
