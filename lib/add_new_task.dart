/*
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils.dart'; // Utilidad que contiene funciones como rgbToHex
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:uuid/uuid.dart'; // Para generar IDs únicos

class AddNewTask extends StatefulWidget {
  final String? taskId;
  final String title;
  final String description;
  final DateTime? date;
  final Color color;
  final bool isEditing;

  const AddNewTask({
    super.key,
    this.taskId,
    this.title = '',
    this.description = '',
    this.date,
    this.color = Colors.blue,
    this.isEditing = false,
  });

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
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
    selectedDate = widget.date ?? DateTime.now();
    _selectedColor = widget.color;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveTaskToDb() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.isEditing && widget.taskId != null && widget.taskId!.isNotEmpty) {
        // Si es edición, actualiza la tarea existente (sin tocar isFavorite)
        await FirebaseFirestore.instance.collection("tasks").doc(widget.taskId).update({
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "date": selectedDate,
          "color": rgbToHex(_selectedColor),
        });
      } else {
        // Si es creación, añade una nueva tarea con isFavorite por defecto
        final id = const Uuid().v4();
        await FirebaseFirestore.instance.collection("tasks").doc(id).set({
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "date": selectedDate,
          "creator": FirebaseAuth.instance.currentUser!.uid,
          "postedAt": FieldValue.serverTimestamp(),
          "color": rgbToHex(_selectedColor),
          "isFavorite": false, // Campo booleano añadido con valor por defecto false
        });
      }
      Navigator.pop(context);
    } catch (e) {
      print("Error al guardar la tarea: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la tarea: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Tarea' : 'Agregar Tarea'),
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
                ColorPicker(
                  pickersEnabled: const {ColorPickerType.wheel: true},
                  color: _selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  heading: const Text('Seleccionar Color'),
                  subheading: const Text('Elegir una tonalidad diferente'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await saveTaskToDb();
                  },
                  child: Text(widget.isEditing ? 'Guardar Cambios' : 'Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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