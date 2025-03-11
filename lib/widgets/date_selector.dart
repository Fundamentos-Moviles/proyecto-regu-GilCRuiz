import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final Function(DateTime)? onDateChanged;

  const DateSelector({super.key, this.onDateChanged});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime selectedDate = DateTime.now();
  int dayOffset = 0; // Desplazamiento en días

  List<DateTime> generateDayDates(int dayOffset) {
    final today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    startOfWeek = startOfWeek.add(Duration(days: dayOffset));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDates = generateDayDates(dayOffset);
    String monthName = DateFormat('MMMM')
        .format(weekDates.first)
        .replaceFirst(weekDates.first.toString()[0], weekDates.first.toString()[0].toUpperCase());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
            bottom: 10.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    dayOffset -= 7; // Retrocede una semana (7 días)
                  });
                },
              ),
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  setState(() {
                    dayOffset += 7; // Avanza una semana (7 días)
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: 14,
              itemBuilder: (context, index) {
                DateTime date = generateDayDates(dayOffset)[index % 7];
                bool isSelected = DateFormat('d').format(selectedDate) ==
                        DateFormat('d').format(date) &&
                    selectedDate.month == date.month &&
                    selectedDate.year == date.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                    if (widget.onDateChanged != null) {
                      widget.onDateChanged!(selectedDate);
                    }
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepOrangeAccent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepOrangeAccent
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          DateFormat('EEEE').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}