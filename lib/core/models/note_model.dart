import 'package:flutter/material.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final int colorHex;
  final bool isPinned;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'General',
    this.colorHex = 0xFF6366F1, // Default indigo color
    this.isPinned = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'colorHex': colorHex,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<dynamic, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'General',
      colorHex: map['colorHex'] ?? 0xFF6366F1,
      isPinned: map['isPinned'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? colorHex,
    bool? isPinned,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      colorHex: colorHex ?? this.colorHex,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Color get cardColor => Color(colorHex);
}
