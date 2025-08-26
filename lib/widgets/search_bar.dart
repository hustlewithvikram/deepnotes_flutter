import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSelectionMode;
  final bool hasFocus;
  final bool hasText;
  final User? user;

  // Extra data for selection
  final bool allSelectedPinned; // true if all selected notes are pinned
  final bool allSelectedUnpinned; // true if all selected notes are unpinned

  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onUnpin;
  final VoidCallback onAccountTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSelectionMode,
    required this.hasFocus,
    required this.hasText,
    required this.user,
    this.allSelectedPinned = false,
    this.allSelectedUnpinned = false,
    required this.onClear,
    required this.onDelete,
    required this.onPin,
    required this.onUnpin,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // 🔍 Search Field
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: isSelectionMode
                    ? controller.text
                    : "Search notes...",
                prefixIcon: isSelectionMode
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : const Icon(Icons.search),
                suffixIcon: hasText
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onClear,
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Selection Mode: PopupMenu for Pin/Unpin/Delete
          if (isSelectionMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) async {
                switch (value) {
                  case 'pin':
                    onPin();
                    break;
                  case 'unpin':
                    onUnpin();
                    break;
                  case 'delete':
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete selected notes?'),
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
                    if (confirm == true) onDelete();
                    break;
                }
              },
              itemBuilder: (_) {
                return [
                  if (allSelectedUnpinned)
                    const PopupMenuItem(value: 'pin', child: Text('Pin')),
                  if (allSelectedPinned)
                    const PopupMenuItem(value: 'unpin', child: Text('Unpin')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ];
              },
            )
          else
            // 👤 Account button
            IconButton(
              icon: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.account_circle, size: 30)
                    : null,
              ),
              onPressed: onAccountTap,
            ),
        ],
      ),
    );
  }
}
