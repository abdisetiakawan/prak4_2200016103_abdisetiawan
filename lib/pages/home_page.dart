import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/barca_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestore = FirestoreService();

  Future<void> _showAddTaskSheet(BuildContext context, String uid) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tambahkan Misi Baru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Judul tugas',
                      hintText: 'Contoh: Menyelesaikan laporan latihan taktik',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul tidak boleh kosong.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Simpan'),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final error = await _firestore.addTask(uid, controller.text.trim());
                      if (!context.mounted) return;
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return BarcaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                'Visca To-Do',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (user?.displayName != null && user!.displayName!.isNotEmpty)
                Text(
                  'Hola, ${user.displayName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Keluar',
              onPressed: () => auth.signOut(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: user == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<Task>>(
                stream: _firestore.watchTasks(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Terjadi kesalahan memuat data.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final tasks = snapshot.data ?? [];
                  if (tasks.isEmpty) {
                    return _EmptyState(onAdd: () => _showAddTaskSheet(context, user.uid));
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    child: ListView.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: ValueKey(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus tugas?'),
                                content: const Text('Apakah kamu yakin ingin menghapus tugas ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            return confirm ?? false;
                          },
                          onDismissed: (_) async {
                            final error = await _firestore.deleteTask(user.uid, task.id);
                            if (!context.mounted) return;
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            }
                          },
                          child: TaskCard(
                            task: task,
                            onToggle: () async {
                              final error = await _firestore.toggleDone(user.uid, task);
                              if (!context.mounted) return;
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error)),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: user == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showAddTaskSheet(context, user.uid),
                icon: const Icon(Icons.add),
                label: const Text('Tugas baru'),
              ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
  });

  final Task task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isDone;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompleted ? AppTheme.gold.withValues(alpha: 0.7) : Colors.transparent,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                color: isCompleted ? AppTheme.gold : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.black)
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.white70 : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (task.timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Dibuat ${_format(task.timestamp!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isCompleted ? Icons.refresh : Icons.check_circle,
              color: isCompleted ? Colors.white54 : AppTheme.gold,
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return 'baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pending_actions, size: 86, color: Colors.white30),
          const SizedBox(height: 16),
          Text(
            'Belum ada misi.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai susun strategi harianmu ala Blaugrana dengan menambah tugas pertama!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tugas perdana'),
          ),
        ],
      ),
    );
  }
}
