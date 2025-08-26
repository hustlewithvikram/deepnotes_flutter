import 'package:flutter/material.dart';
import '../database/models/note.dart';
import '../database/app_database.dart';

class NoteEditor extends StatefulWidget {
  final Note? note; // nullable for new note
  final AppDatabase db = AppDatabase.instance;

  NoteEditor({super.key, this.note});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController = TextEditingController(text: widget.note?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveNote() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty && description.isEmpty) return;

    if (widget.note == null) {
      // Insert new note
      await widget.db.insertNote(Note(
        title: title,
        description: description,
        createdAt: DateTime.now(),
        isPinned: false,
      ));
    } else {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: title,
        description: description,
      );
      await widget.db.updateNote(updatedNote);
    }

    Navigator.pop(context, true); // return true to trigger reload
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 24),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: "Write a note",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
