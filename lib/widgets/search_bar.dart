import 'package:deepnotes_flutter/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSelectionMode;
  final bool hasFocus;
  final bool hasText;
  final User? user;
  final bool allSelectedPinned;
  final bool allSelectedUnpinned;
  final int selectedCount;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onUnpin;
  final VoidCallback onAccountTap;
  final ValueChanged<String>? onSearchChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSelectionMode,
    required this.hasFocus,
    required this.hasText,
    required this.user,
    required this.selectedCount, // Make this required
    this.allSelectedPinned = false,
    this.allSelectedUnpinned = false,
    required this.onClear,
    required this.onDelete,
    required this.onPin,
    required this.onUnpin,
    required this.onAccountTap,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeUtils.getThemeMode() == ThemeMode.dark;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            // Search/Selection Text Field
            _buildTextField(context, isDarkMode, theme),

            const SizedBox(width: 10),

            // Fixed size container for the action button
            SizedBox(
              width: 48,
              height: 48,
              child: _buildActionButton(isDarkMode, context, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    bool isDarkMode,
    ThemeData theme,
  ) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onSearchChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: isSelectionMode ? controller.text : "Search notes...",
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
          prefixIcon: isSelectionMode
              ? _buildSelectionCountBadge(
                  theme,
                ) // Show count badge instead of check icon
              : const Icon(Icons.search, size: 24),
          suffixIcon: _buildSuffixIcon(),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // Build selection count badge
  Widget _buildSelectionCountBadge(ThemeData theme) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          selectedCount.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (hasText) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 20),
        onPressed: onClear,
        tooltip: 'Clear search',
        iconSize: 20,
      );
    }
    return null;
  }

  Widget _buildActionButton(
    bool isDarkMode,
    BuildContext context,
    ThemeData theme,
  ) {
    if (isSelectionMode) {
      return _buildSelectionActionsMenu(isDarkMode, context, theme);
    } else {
      return _buildAccountButton(isDarkMode);
    }
  }

  Widget _buildSelectionActionsMenu(
    bool isDarkMode,
    BuildContext context,
    ThemeData theme,
  ) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: theme.cardColor,
      elevation: 4,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_vert,
          color: theme.colorScheme.primary,
          size: 24,
        ),
      ),
      onSelected: (value) => _handleMenuSelection(value, context),
      itemBuilder: (_) => _buildMenuItems(theme),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(ThemeData theme) {
    return [
      // Always show both pin and unpin options, but disable inappropriate ones
      PopupMenuItem<String>(
        value: 'pin',
        enabled: allSelectedUnpinned,
        child: ListTile(
          dense: true,
          leading: Icon(
            Icons.push_pin,
            size: 20,
            color: allSelectedUnpinned
                ? theme.colorScheme.primary
                : theme.disabledColor,
          ),
          title: Text(
            'Pin ($selectedCount)',
            style: TextStyle(
              color: allSelectedUnpinned
                  ? theme.colorScheme.onSurface
                  : theme.disabledColor,
            ),
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: 'unpin',
        enabled: allSelectedPinned,
        child: ListTile(
          dense: true,
          leading: Icon(
            Icons.push_pin_outlined,
            size: 20,
            color: allSelectedPinned
                ? theme.colorScheme.primary
                : theme.disabledColor,
          ),
          title: Text(
            'Unpin ($selectedCount)',
            style: TextStyle(
              color: allSelectedPinned
                  ? theme.colorScheme.onSurface
                  : theme.disabledColor,
            ),
          ),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'delete',
        child: ListTile(
          dense: true,
          leading: Icon(Icons.delete_outline, size: 20, color: Colors.red),
          title: Text(
            'Delete ($selectedCount)',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    ];
  }

  Future<void> _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'pin':
        if (allSelectedUnpinned) onPin();
        break;
      case 'unpin':
        if (allSelectedPinned) onUnpin();
        break;
      case 'delete':
        final confirmed = await _showDeleteConfirmationDialog(context);
        if (confirmed) onDelete();
        break;
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete $selectedCount note${selectedCount > 1 ? 's' : ''}?',
        ),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Widget _buildAccountButton(bool isDarkMode) {
    return IconButton(
      iconSize: 40,
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
        backgroundImage: user?.photoURL != null
            ? NetworkImage(user!.photoURL!)
            : null,
        child: user?.photoURL == null
            ? Icon(
                Icons.account_circle,
                size: 32,
                color: isDarkMode ? Colors.white : Colors.black54,
              )
            : null,
      ),
      onPressed: onAccountTap,
      tooltip: 'Account',
    );
  }
}
