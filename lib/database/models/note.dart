class Note {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isPinned;

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isPinned,
  });

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
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      isPinned: map['isPinned'] == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // NEW: copyWith method for easy updates
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
}
