import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';
import 'package:mobile_assignment/feature/tasks/providers/task_provider.dart';

class DeadlineReminderScreen extends StatefulWidget {
  static const String routeName = '/deadline_reminder';

  const DeadlineReminderScreen({super.key});

  @override
  State<DeadlineReminderScreen> createState() => _DeadlineReminderScreenState();
}

class _DeadlineReminderScreenState extends State<DeadlineReminderScreen> {
  Task? _selectedTask;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<TaskProvider>();
      if (provider.tasks.isEmpty && !provider.isLoading) {
        provider.loadTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;
    final today = DateTime.now();
    final dueDate = _selectedTask?.dueDate;
    final remaining = _selectedTask != null
        ? provider.remainingFor(_selectedTask!, now: today)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Deadline Reminder',
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.background),
        backgroundColor: AppColors.text,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a task',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Task>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.text.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    hint: const Text('Choose task'),
                    value: _selectedTask != null && tasks.contains(_selectedTask)
                        ? _selectedTask
                        : null,
                    items: tasks
                        .map(
                          (task) => DropdownMenuItem<Task>(
                            value: task,
                            child: Text(
                              task.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (task) => setState(() => _selectedTask = task),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedTask != null) ...[
                    _infoCard(
                      title: 'Task Due Date',
                      value: _formatDate(dueDate!),
                      icon: Icons.event_outlined,
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      title: 'Current Date',
                      value: _formatDate(today),
                      icon: Icons.today_outlined,
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      title: 'Time Remaining',
                      value: provider.remainingLabelFor(
                        _selectedTask!,
                        now: today,
                      ),
                      icon: Icons.timer_outlined,
                      valueColor: remaining!.isNegative
                          ? Colors.red.shade700
                          : AppColors.text,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'No tasks available. Please add a task first.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }
}
