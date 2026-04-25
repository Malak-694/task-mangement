// lib/feature/tasks/screens/task_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/tasks/providers/task_provider.dart';
import 'package:mobile_assignment/feature/tasks/screens/new_task_screen.dart';
import 'package:mobile_assignment/feature/tasks/screens/profile_screen.dart';
import 'package:mobile_assignment/feature/tasks/widgets/task_card.dart';

class TaskScreen extends StatefulWidget {
  static const String routeName = '/tasks';
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    // Load once when screen opens
    Future.microtask(() => context.read<TaskProvider>().loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    // watch → rebuilds whenever TaskProvider calls notifyListeners()
    final provider = context.watch<TaskProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Tasks',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: AppColors.background),
          ),
          backgroundColor: AppColors.text,
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, ProfileScreen.routeName),
              icon: const Icon(Icons.person, color: AppColors.button),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${provider.count} Tasks',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, NewTaskScreen.routeName);
                      // No manual reload needed — provider already updated
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      '+ new task',
                      style: TextStyle(color: AppColors.buttonText, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.tasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                  onRefresh: () => context.read<TaskProvider>().loadTasks(),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: provider.tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];
                      return TaskCard(
                        task: task,
                        onEdited: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewTaskScreen(taskToEdit: task),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_outlined, size: 72, color: AppColors.primary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('No tasks yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 8),
          Text('Tap "+ new task" to get started',
              style: TextStyle(fontSize: 14, color: AppColors.text.withOpacity(0.6))),
        ],
      ),
    );
  }
}