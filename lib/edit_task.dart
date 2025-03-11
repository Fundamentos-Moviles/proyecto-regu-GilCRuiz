import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils.dart';
import 'package:intl/intl.dart';
import 'package:frontend/widgets/color_selector.dart';

// Clase que representa la pantalla para editar una tarea existente
class EditTask extends StatefulWidget {
  final String taskId;
  final String title;
  final String description;
  final DateTime date;
  final Color color;

  const EditTask({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  @override
  State<EditTask> createState() => _EditTaskState();
}

// Estado de la pantalla EditTask
class _EditTaskState extends State<EditTask> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late DateTime selectedDate;
  late Color _selectedColor;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    selectedDate = widget.date;
    _selectedColor = widget.color;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateTaskInDb() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection("tasks")
          .doc(widget.taskId)
          .update({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "date": selectedDate,
        "color": rgbToHex(_selectedColor),
      });
      Navigator.pop(context);
    } catch (e) {
      print("Error al actualizar la tarea: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la tarea: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('TextStyle heredado para labelLarge: ${Theme.of(context).textTheme.labelLarge}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarea'),
        actions: [
          GestureDetector(
            onTap: () async {
              final selDate = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (selDate != null) {
                setState(() {
                  selectedDate = selDate;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(DateFormat('dd-MM-y').format(selectedDate)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ColorSelector(
                  initialColor: _selectedColor,
                  onColorChanged: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await updateTaskInDb();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    foregroundColor: Colors.white, // Forzar texto blanco
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Forzar blanco localmente
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}