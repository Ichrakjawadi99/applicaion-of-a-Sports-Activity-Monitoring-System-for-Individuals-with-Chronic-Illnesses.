import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, String> _trainings = {};

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Calendrier'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: Colors.white),
              weekendTextStyle: TextStyle(color: Colors.white),
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
            eventLoader: (day) {
              return _trainings[day] != null ? [_trainings[day]] : [];
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              headerPadding: const EdgeInsets.symmetric(vertical: 20.0),
              titleTextStyle: TextStyle(
                color: Colors.lightGreenAccent,
                fontSize: 20.0,
              ),
              leftChevronIcon:
                  Icon(Icons.arrow_back_ios, color: Colors.lightGreenAccent),
              rightChevronIcon:
                  Icon(Icons.arrow_forward_ios, color: Colors.lightGreenAccent),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Center(
                    child: Text(
                      events[0].toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tu es en train de t\'entraîner aujourd\'hui?',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (_selectedDay != null) {
                    setState(() {
                      _trainings[_selectedDay!] = '😊'; // Happy emoji
                      _trainings.forEach((key, value) {
                        if (key.isBefore(DateTime.now().subtract(Duration(days: 365)))) {
                          _trainings.remove(key);
                        }
                      });
                    });
                  }
                },
                icon: Icon(Icons.check),
                label: Text('Oui'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_selectedDay != null) {
                    setState(() {
                      _trainings[_selectedDay!] = '😢'; // Sad emoji
                      _trainings.forEach((key, value) {
                        if (key.isBefore(DateTime.now().subtract(Duration(days: 365)))) {
                          _trainings.remove(key);
                        }
                      });
                    });
                  }
                },
                icon: Icon(Icons.close),
                label: Text('Non'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CalendarPage(),
  ));
}
