// lib/feature/tasks/screens/new_task_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/core/validator/added_task_validator.dart';
import 'package:mobile_assignment/feature/tasks/Services/task_reprositry.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';
import 'package:mobile_assignment/feature/tasks/Services/local_task_service.dart';
import 'package:mobile_assignment/feature/tasks/widgets/lebal.dart';
import 'package:mobile_assignment/feature/tasks/widgets/field.dart';
import 'package:mobile_assignment/feature/tasks/widgets/priority_selector.dart';

class NewTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  static const routeName = '/handel_task';
  const NewTaskScreen({super.key, this.taskToEdit});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  DateTime _dueDate = DateTime.now();
  String _priority = 'medium';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    if (widget.taskToEdit != null) {
      _titleCtrl = TextEditingController(text: widget.taskToEdit!.title);
      _descCtrl = TextEditingController(text: widget.taskToEdit!.description ?? '');
      _dueDate = widget.taskToEdit!.dueDate;
      _priority = widget.taskToEdit!.priority;
    } else {
      _titleCtrl = TextEditingController();
      _descCtrl = TextEditingController();
      _dueDate = DateTime.now();
      _priority = 'medium';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }


  String get _formattedDate {
    final d = _dueDate;
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.background,
            onSurface: AppColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final task = Task(
        id: widget.taskToEdit?.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        dueDate: _dueDate,
        priority: _priority,
        createdAt: widget.taskToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.taskToEdit != null) {
        await TaskRepository.instance.updateTask(task);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(' Task updated successfully!'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await TaskRepository.instance.insertTask(task);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(' Task saved successfully!'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint(' Error saving task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: AppColors.button,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteTask() async {
    if (widget.taskToEdit?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.button)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await TaskRepository.instance.deleteTask(widget.taskToEdit!.id as Task);
        if (mounted) {
          Navigator.pop(context, true); // Return true to refresh list
        }
      } catch (e) {
        debugPrint('Error deleting: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: isEditing
            ? [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.button),
            onPressed: _deleteTask,
            tooltip: 'Delete Task',
          ),
        ]
            : null,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label('Task Title', required: true),
                Field(
                  controller: _titleCtrl,
                  hint: 'e.g., Source velvet cushions...',
                  validator: TaskValidator.title,
                ),

                const SizedBox(height: 28),

                Label('Description'),
                Field(
                  controller: _descCtrl,
                  hint: 'Add notes, material pairings...',
                  maxLines: 4,
                ),

                const SizedBox(height: 28),

                Label('Due Date', required: true),
                const SizedBox(height: 8),
                FormField<String>(
                  validator: (_) => TaskValidator.dueDate(_formattedDate),
                  builder: (state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: state.hasError
                                  ? AppColors.button
                                  : AppColors.text.withOpacity(0.15),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.text.withOpacity(0.45),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _formattedDate,
                                  style: const TextStyle(fontSize: 15, color: AppColors.text),
                                ),
                              ),
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                                color: AppColors.text.withOpacity(0.35),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            state.errorText!,
                            style: const TextStyle(fontSize: 12, color: AppColors.button),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Label('Priority Level', required: true),
                const SizedBox(height: 12),
                PrioritySelector(
                  initialValue: _priority,
                  validator: (_) => TaskValidator.priority(_priority),
                  onChanged: (val) => setState(() => _priority = val),
                ),

                const SizedBox(height: 250),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: AppColors.buttonText,
                      minimumSize: const Size(double.infinity, 45),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.background,
                      ),
                    )
                        : Text(
                      isEditing ? ' Update Task' : 'Save Task',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}