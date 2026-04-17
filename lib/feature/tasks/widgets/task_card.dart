import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/tasks/widgets/priority_badge.dart' show PriorityBadge;
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';
import 'package:mobile_assignment/feature/tasks/Services/task_reprositry.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onDeleted;
  final VoidCallback? onEdited;

  const TaskCard({
    super.key,
    required this.task,
    this.onDeleted,
    this.onEdited,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.task.isCompleted;
  }

  Future<void> _toggleCompletion(bool completed) async {
    setState(() => _isDone = completed);
    await TaskRepository.instance.markCompleted(widget.task, completed);
  }

  Future<void> _deleteTask() async {
    try {
      await TaskRepository.instance.deleteTask(widget.task);
      if (mounted && widget.onDeleted != null) {
        widget.onDeleted!();
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  void _onEditTap() {
    if (widget.onEdited != null) {
      widget.onEdited!();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final taskKey = widget.task.id ?? widget.task.createdAt.millisecondsSinceEpoch;
    final dueDate = widget.task.dueDate;
    final isOverdue = dueDate.isBefore(DateTime.now()) && !widget.task.isCompleted;

    return Dismissible(
      key: ValueKey(taskKey),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _deleteTask(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDone
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PriorityBadge(label: widget.task.priority),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _isDone ? AppColors.text.withOpacity(0.4) : AppColors.text,
                      decoration: _isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: AppColors.text.withOpacity(0.4),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleCompletion(!_isDone),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isDone ? AppColors.button : Colors.transparent,
                      border: Border.all(
                        color: _isDone ? AppColors.button : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: _isDone
                        ? const Icon(Icons.check, size: 13, color: AppColors.buttonText)
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            if (widget.task.description?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.task.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.text.withOpacity(0.65),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 16),

            Divider(
              color: AppColors.primary.withOpacity(0.25),
              height: 1,
              thickness: 0.5,
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.secondary.withOpacity(0.6),
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue
                        ? Colors.red.shade400
                        : AppColors.secondary.withOpacity(0.6),
                    fontWeight: isOverdue ? FontWeight.w600 : null,
                  ),
                ),

                const Spacer(),
                InkWell(
                  onTap: _onEditTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}