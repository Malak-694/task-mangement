// lib/feature/tasks/screens/new_task_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/core/validator/added_task_validator.dart';
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';
import 'package:mobile_assignment/feature/tasks/providers/task_provider.dart';
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
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  DateTime _dueDate = DateTime.now();
  String _priority = 'medium';
  bool _isFavorite = false;
  bool _isSaving = false;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final t = widget.taskToEdit;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    if (t != null) {
      _dueDate = t.dueDate;
      _priority = t.priority;
      _isFavorite = t.isFavorite;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
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
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final task = Task(
      id: widget.taskToEdit?.id,
      firebaseId: widget.taskToEdit?.firebaseId,
      uid: widget.taskToEdit?.uid,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : null,
      dueDate: _dueDate,
      priority: _priority,
      createdAt: widget.taskToEdit?.createdAt,
      isCompleted: widget.taskToEdit?.isCompleted ?? false,
      isFavorite: _isFavorite,
    );

    try {
      final provider = context.read<TaskProvider>();
      _isEditing
          ? await provider.updateTask(task)
          : await provider.addTask(task);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Task updated successfully!'
                  : 'Task saved successfully!',
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
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
    final task = widget.taskToEdit;
    if (task == null) return;

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
      await context.read<TaskProvider>().deleteTask(
        task,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.button,
                  ),
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
                  focusNode: _titleFocus,
                  hint: 'e.g., mobile assigment ...',
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_descriptionFocus),
                  validator: TaskValidator.title,
                ),

                const SizedBox(height: 28),
                Label('Description'),
                Field(
                  controller: _descCtrl,
                  focusNode: _descriptionFocus,
                  hint: 'Add notes, material pairings...',
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
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
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.text,
                                  ),
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
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.button,
                            ),
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

                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Mark as favorite',
                    style: TextStyle(color: AppColors.text),
                  ),
                  value: _isFavorite,
                  activeColor: AppColors.button,
                  onChanged: (value) => setState(() => _isFavorite = value),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: AppColors.buttonText,
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
                            _isEditing ? 'Update Task' : 'Save Task',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
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
