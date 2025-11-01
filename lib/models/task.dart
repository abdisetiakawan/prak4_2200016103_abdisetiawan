import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final bool isDone;
  final DateTime? timestamp;

  const Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.timestamp,
  });

  factory Task.fromDoc(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] as String? ?? 'Tanpa judul',
      isDone: data['isDone'] as bool? ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
    DateTime? timestamp,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
