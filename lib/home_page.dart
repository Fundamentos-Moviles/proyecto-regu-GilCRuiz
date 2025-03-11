import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/add_new_task.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widgets/date_selector.dart';
import 'package:frontend/widgets/task_card.dart';
import 'package:frontend/widgets/custom_drawer.dart'; // Nuevo import


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _selectedDate;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _updateSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _markAsFavorite(String taskId, bool currentFavoriteStatus) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'isFavorite': !currentFavoriteStatus,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!currentFavoriteStatus
              ? "Tarea marcada como favorita"
              : "Tarea retirada de favoritos"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void _deleteNote(String taskId) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tarea eliminada"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  Widget _buildTaskItem(QueryDocumentSnapshot doc) {
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
          _deleteNote(taskId);
        } else if (direction == DismissDirection.endToStart) {
          _markAsFavorite(taskId, isFavorite);
        }
        setState(() {});
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewTask(
                taskId: taskId,
                title: taskData['title'] as String? ?? '',
                description: taskData['description'] as String? ?? '',
                date: date?.toDate(),
                color: hexToColor(taskData['color'] as String? ?? '#000000'),
                isEditing: true,
              ),
            ),
          );
        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text('Mis Notas'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddNewTask(date: _selectedDate, isEditing: false),
                ),
              );
            },
            icon: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
      drawer: const CustomDrawer(), // Usar el widget CustomDrawer
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Center(
          child: Column(
            children: [
              DateSelector(onDateChanged: _updateSelectedDate),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("tasks")
                      .where('creator',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Text('No hay notas aqui :(');
                    }

                    final tasks = snapshot.data!.docs.where((doc) {
                      final taskData =
                          doc.data() as Map<String, dynamic>? ?? {};
                      final date = taskData['date'] as Timestamp?;
                      if (_selectedDate == null || date == null) return false;
                      final taskDate = date.toDate();
                      return taskDate.year == _selectedDate!.year &&
                          taskDate.month == _selectedDate!.month &&
                          taskDate.day == _selectedDate!.day;
                    }).toList();

                    if (tasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/img/perrotriste.png',
                                width: 350, height: 350),
                            const Text(
                              'No hay tareas para este día :(',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final favoriteTasks = tasks.where((doc) {
                      final taskData =
                          doc.data() as Map<String, dynamic>? ?? {};
                      return taskData['isFavorite'] == true;
                    }).toList();
                    final nonFavoriteTasks = tasks.where((doc) {
                      final taskData =
                          doc.data() as Map<String, dynamic>? ?? {};
                      return taskData['isFavorite'] != true;
                    }).toList();

                    if (favoriteTasks.isNotEmpty) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Favoritas',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: favoriteTasks.length,
                            itemBuilder: (context, index) {
                              return _buildTaskItem(favoriteTasks[index]);
                            },
                          ),
                          if (nonFavoriteTasks.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Otras Tareas',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: nonFavoriteTasks.length,
                              itemBuilder: (context, index) {
                                return _buildTaskItem(nonFavoriteTasks[index]);
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskItem(tasks[index]);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}