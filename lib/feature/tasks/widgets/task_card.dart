import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assignment/core/style/colors.dart';
import 'package:mobile_assignment/feature/tasks/widgets/priority_badge.dart'
    show PriorityBadge;
import 'package:mobile_assignment/feature/tasks/models/task_model.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onDeleted;
  final VoidCallback? onEdited;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onToggleFavorite;
  final bool showDeleteEditAction;
  final bool showFavoriteAction;

  const TaskCard({
    super.key,
    required this.task,
    this.onDeleted,
    this.onEdited,
    this.onToggleComplete,
    this.onToggleFavorite,
    this.showFavoriteAction = true,
    this.showDeleteEditAction = true,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
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
    final taskKey =
        widget.task.id ?? widget.task.createdAt.millisecondsSinceEpoch;
    final dueDate = widget.task.dueDate;
    final isOverdue =
        dueDate.isBefore(DateTime.now()) && !widget.task.isCompleted;

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
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete task?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (_) => widget.onDeleted?.call(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.task.isCompleted
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PriorityBadge(label: widget.task.priority),
                const Spacer(),
                if (widget.showFavoriteAction)
                  InkWell(
                    onTap: widget.onToggleFavorite,
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(
                      widget.task.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.task.isFavorite
                          ? AppColors.button
                          : AppColors.secondary.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: widget.onToggleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.task.isCompleted
                          ? AppColors.button
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.task.isCompleted
                            ? AppColors.button
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: widget.task.isCompleted
                        ? const Icon(
                      Icons.check,
                      size: 13,
                      color: AppColors.buttonText,
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: widget.task.isCompleted
                              ? AppColors.text.withOpacity(0.4)
                              : AppColors.text,
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppColors.text.withOpacity(0.4),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                    ],
                  ),
                ),
              ],
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
                if (widget.showDeleteEditAction) ...[
                  InkWell(
                    onTap: _onEditTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onDeleted,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}