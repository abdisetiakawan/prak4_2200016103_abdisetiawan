import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) {
    return _db.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<Task>> watchTasks(String uid) {
    return _tasksRef(uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromDoc(doc.id, doc.data()))
            .toList());
  }

  Future<String?> addTask(String uid, String title) async {
    try {
      await _tasksRef(uid).add({
        'title': title,
        'isDone': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Gagal menambahkan tugas: $e';
    }
  }

  Future<String?> toggleDone(String uid, Task task) async {
    try {
      await _tasksRef(uid).doc(task.id).update({'isDone': !task.isDone});
      return null;
    } catch (e) {
      return 'Gagal memperbarui tugas: $e';
    }
  }

  Future<String?> deleteTask(String uid, String taskId) async {
    try {
      await _tasksRef(uid).doc(taskId).delete();
      return null;
    } catch (e) {
      return 'Gagal menghapus tugas: $e';
    }
  }
}
