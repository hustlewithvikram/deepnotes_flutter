class Note {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isPinned;

  const Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isPinned,
  });

  // Empty note factory constructor
  factory Note.empty() {
    return Note(
      id: null,
      title: '',
      description: '',
      createdAt: DateTime.now(),
      isPinned: false,
    );
  }

  // Convenience constructor for new notes
  factory Note.create({
    required String title,
    required String description,
    bool isPinned = false,
  }) {
    return Note(
      id: null,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      isPinned: isPinned,
    );
  }

  // Convert Note to Map (for DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
    };
  }

  // Convert Map from DB to Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isPinned: map['isPinned'] == 1,
    );
  }

  // Check if note is valid (has title or description)
  bool get isValid => title.trim().isNotEmpty || description.trim().isNotEmpty;

  // Check if note is empty
  bool get isEmpty => title.isEmpty && description.isEmpty;

  // Get preview text (first line of description or empty)
  String get preview {
    if (description.isEmpty) return '';
    final lines = description.split('\n');
    return lines.first;
  }

  // Get character count
  int get characterCount => title.length + description.length;

  // Get word count
  int get wordCount {
    final titleWords = title
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    final descWords = description
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    return titleWords.length + descWords.length;
  }

  // CopyWith method for easy updates
  Note copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  // Merge with another note (useful for updates)
  Note merge(Note other) {
    return copyWith(
      title: other.title.isNotEmpty ? other.title : title,
      description: other.description.isNotEmpty
          ? other.description
          : description,
      isPinned: other.isPinned,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Note) return false;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.isPinned == isPinned;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, createdAt, isPinned);
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, description: ${description.length} chars, '
        'createdAt: $createdAt, isPinned: $isPinned)';
  }

  // JSON serialization for API or storage
  Map<String, dynamic> toJson() => toMap();

  factory Note.fromJson(Map<String, dynamic> json) => Note.fromMap(json);

  // Comparison methods
  bool isSameContent(Note other) {
    return title == other.title &&
        description == other.description &&
        isPinned == other.isPinned;
  }

  // Time-related helpers
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  bool get isRecent {
    return isToday || isThisWeek;
  }
}
