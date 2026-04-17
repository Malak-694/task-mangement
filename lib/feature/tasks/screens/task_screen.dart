// lib/feature/tasks/screens/task_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/tasks/Services/task_reprositry.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';
import 'package:mobile_assignment/feature/tasks/Services/local_task_service.dart';
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
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      _tasks = await TaskRepository.instance.getAllTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onTaskDeleted() {
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            "Tasks",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.background,
            ),
          ),
          backgroundColor: AppColors.text,
          actions: [
            IconButton(onPressed: (){
              Navigator.pushNamed(context, ProfileScreen.routeName);
            }, icon: Icon(Icons.person , color: AppColors.button,))
          ],
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Text(
                    "${_tasks.length} Tasks",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        NewTaskScreen.routeName,
                      );
                      if (result == true) _loadTasks(); // Refresh if task was saved
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "+ new task",
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                  onRefresh: _loadTasks,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: _tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: _tasks[index],
                        onEdited: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NewTaskScreen(taskToEdit: _tasks[index]),
                            ),
                          );
                          if (result == true) _loadTasks(); // Refresh list
                        },
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
          Icon(
            Icons.task_alt_outlined,
            size: 72,
            color: AppColors.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "+ new task" to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}