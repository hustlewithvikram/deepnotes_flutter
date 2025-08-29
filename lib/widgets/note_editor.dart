import 'package:flutter/material.dart';
import '../database/models/note.dart';
import '../database/app_database.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;
  const NoteEditor({super.key, this.note});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final AppDatabase _db = AppDatabase.instance;

  bool _isSaving = false;
  bool _isPinned = false;
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController = TextEditingController(text: widget.note?.description ?? '');
    _isPinned = widget.note?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveAndExit() async {
    if (_isSaving) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // If nothing to save, just exit without touching DB.
    if (title.isEmpty && description.isEmpty) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (widget.note == null) {
        await _db.insertNote(
          Note(
            title: title,
            description: description,
            createdAt: DateTime.now(),
            isPinned: _isPinned,
          ),
        );
      } else {
        await _db.updateNote(
          widget.note!.copyWith(
            title: title,
            description: description,
            isPinned: _isPinned,
          ),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save note: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _togglePinned() {
    setState(() => _isPinned = !_isPinned);
  }

  void _insertChecklist() {
    final selection = _descriptionController.selection;
    final position = selection.baseOffset;
    final text = _descriptionController.text;

    String newText;
    if (position == -1) {
      newText = '$text\n- [ ] ';
    } else {
      newText =
          '${text.substring(0, position)}\n- [ ] ${text.substring(position)}';
    }

    _descriptionController.value = _descriptionController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: position + 7),
    );
  }

  int get _wordCount {
    final titleWords = _titleController.text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    final descWords = _descriptionController.text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    return titleWords + descWords;
  }

  int get _charCount {
    return _titleController.text.length + _descriptionController.text.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _saveAndExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: _isSaving ? null : _saveAndExit,
          ),
          title: Text(widget.note == null ? 'New note' : 'Edit note'),
          actions: [
            // Pin action
            IconButton(
              icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              tooltip: _isPinned ? 'Unpin note' : 'Pin note',
              onPressed: _togglePinned,
            ),

            // Checklist action
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: 'Add checklist',
              onPressed: _insertChecklist,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        hintStyle: theme.textTheme.headlineSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: widget.note == null,
                    ),

                    const SizedBox(height: 8),

                    // Divider
                    Divider(color: cs.outlineVariant, height: 1),

                    const SizedBox(height: 16),

                    // Description field
                    Expanded(
                      child: TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Start typing...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),

                    // Statistics
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$_charCount chars • $_wordCount words',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
