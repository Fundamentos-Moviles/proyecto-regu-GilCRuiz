import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widgets/task_card.dart';

// Mensajes centralizados
class AppMessages {
  static const String taskDeleted = 'Tarea eliminada';
  static const String taskFavorited = 'Tarea marcada como favorita';
  static const String taskUnfavorited = 'Tarea retirada de favoritos';
}

Widget buildTaskItem(
  QueryDocumentSnapshot doc,
  BuildContext context, {
  required Function(String, bool) onMarkAsFavorite,
  required Function(String) onDelete,
  required Function(String) onTap, // Nueva función para manejar el tap
}) {
  final taskData = doc.data() as Map<String, dynamic>? ?? {};
  final taskId = doc.id;
  final isFavorite = taskData['isFavorite'] as bool? ?? false;
  final date = taskData['date'] as Timestamp?;

  final scheduledDate = date != null
      ? DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000)
          .toString()
          .split(' ')[0]
      : 'Fecha no disponible';

  return Dismissible(
    key: Key(taskId),
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 30),
    ),
    secondaryBackground: Container(
      color: Colors.amber,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.star, color: Colors.white, size: 30),
    ),
    onDismissed: (direction) {
      if (direction == DismissDirection.startToEnd) {
        onDelete(taskId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppMessages.taskDeleted),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      } else if (direction == DismissDirection.endToStart) {
        onMarkAsFavorite(taskId, isFavorite);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !isFavorite
                  ? AppMessages.taskFavorited
                  : AppMessages.taskUnfavorited,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    },
    child: GestureDetector(
      onTap: () => onTap(taskId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TaskCard(
                color: hexToColor(taskData['color'] as String? ?? '#000000'),
                headerText: taskData['title'] as String? ?? 'Sin título',
                descriptionText:
                    taskData['description'] as String? ?? 'Sin descripción',
                scheduledDate: scheduledDate,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite
                    ? Colors.amber
                    : const Color.fromARGB(255, 255, 255, 255),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}