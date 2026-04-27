import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';
import 'package:mobile_assignment/feature/tasks/providers/task_provider.dart';
import 'package:mobile_assignment/feature/tasks/screens/new_task_screen.dart';
import 'package:mobile_assignment/feature/tasks/widgets/task_card.dart';
import 'package:provider/provider.dart';

class FavoriteTasksScreen extends StatelessWidget {
  static const String routeName = '/favorite_tasks';

  const FavoriteTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final favoriteTasks = provider.favoriteTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Favorite Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.background,
          ),
        ),
        backgroundColor: AppColors.text,
        iconTheme: const IconThemeData(color: AppColors.button),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: favoriteTasks.isEmpty
            ? const Center(
                child: Text(
                  'No favorite tasks yet.',
                  style: TextStyle(fontSize: 16, color: AppColors.text),
                ),
              )
            : ListView.separated(
                itemCount: favoriteTasks.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = favoriteTasks[index];
                  return TaskCard(
                    task: task,
                    onDeleted: () => _deleteTask(context, task),
                    onEdited: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewTaskScreen(taskToEdit: task),
                      ),
                    ),
                    onToggleComplete: () =>
                        context.read<TaskProvider>().toggleComplete(task),
                    onToggleFavorite: () =>
                        context.read<TaskProvider>().toggleFavorite(task),
                    showDeleteEditAction: false,
                  );
                },
              ),
      ),
    );
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<TaskProvider>().deleteTask(task);
    }
  }
}
