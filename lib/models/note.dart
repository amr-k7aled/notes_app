import 'dart:convert';

enum NoteType { note, todo }

class TodoItem {
  final String id;
  String text;
  bool isDone;

  TodoItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  TodoItem copyWith({String? id, String? text, bool? isDone}) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isDone': isDone,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        text: json['text'] as String,
        isDone: json['isDone'] as bool,
      );
}

class Note {
  final String id;
  String title;
  String content;
  NoteType type;
  List<TodoItem> todoItems;
  DateTime createdAt;
  DateTime updatedAt;
  int colorIndex;

  Note({
    required this.id,
    required this.title,
    this.content = '',
    this.type = NoteType.note,
    List<TodoItem>? todoItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.colorIndex = 0,
  })  : todoItems = todoItems ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    List<TodoItem>? todoItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? colorIndex,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      todoItems: todoItems ?? this.todoItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'type': type.name,
        'todoItems': todoItems.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'colorIndex': colorIndex,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String? ?? '',
        type: NoteType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NoteType.note,
        ),
        todoItems: (json['todoItems'] as List<dynamic>? ?? [])
            .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        colorIndex: json['colorIndex'] as int? ?? 0,
      );

  String toJsonString() => jsonEncode(toJson());
  factory Note.fromJsonString(String jsonString) =>
      Note.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
