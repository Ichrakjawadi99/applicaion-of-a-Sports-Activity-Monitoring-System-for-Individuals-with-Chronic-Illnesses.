// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sort_child_properties_last, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        playSound: true,
        vibrationPattern: lowVibrationPattern,
      )
    ],
  );
  runApp(AlarmPage());
}

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  late String _timeString;
  bool waterReminderOn = false;
  bool soundOn = true;
  bool vibrationOn = true;
  Timer? waterReminderTimer;
  List<Widget> _reminders = [];

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    _reminders = [
      ReminderCard(
        title: 'Training Reminder',
        onPressed: () {
          _showTimePicker('Training Reminder', 'Let\'s training honey');
        },
      ),
      ReminderCard(
        title: 'Medication Reminder',
        onPressed: () {
          _showTimePicker(
              'Medication Reminder', 'Don\'t forget your medication');
        },
      ),
      SizedBox(
        height: 20,
      ), // Ajout d'un espace entre l'horloge et les autres widgets
      WaterReminderCard(
        title: 'Water Reminder',
        switchOn: waterReminderOn,
        onSwitchChanged: (bool value) {
          setState(() {
            waterReminderOn = value;
            if (waterReminderOn) {
              _startWaterReminder();
            } else {
              _cancelWaterReminder();
            }
          });
        },
      ),
    ];
  }

  void _getTime() {
    final String formattedDateTime = _formatDateTime(DateTime.now());
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  void _showNotification(String title, String body, Duration delay) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar(
          second: DateTime.now().second + delay.inSeconds, repeats: true),
    );
  }

  void _startWaterReminder() {
    waterReminderTimer = Timer.periodic(
        Duration(minutes: 1),
        (Timer t) => _showNotification('Water Reminder',
            'Don\'t forget to drink water', Duration(minutes: 1)));
  }

  void _cancelWaterReminder() {
    waterReminderTimer?.cancel();
  }

  Future<void> _showAddReminderDialog() async {
    String title = '';
    String message = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(hintText: "Enter reminder title"),
              ),
              TextField(
                onChanged: (value) {
                  message = value;
                },
                decoration: InputDecoration(hintText: "Enter reminder message"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  _reminders.add(
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: ReminderCard(
                        title: title,
                        onPressed: () {
                          _showTimePicker(title, message);
                        },
                      ),
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTimePicker(String title, String message) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
          now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
      _showNotification(title, message, selectedDateTime.difference(now));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Alarm Page'),
          backgroundColor: Colors.green,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.volume_up),
              color: soundOn ? Colors.white : Colors.grey,
              onPressed: () {
                setState(() {
                  soundOn = !soundOn;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.vibration),
              color: vibrationOn ? Colors.white : Colors.grey,
              onPressed: () {
                setState(() {
                  vibrationOn = !vibrationOn;
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    _timeString,
                    style: TextStyle(
                      fontSize: 60.0,
                      color: Colors.white,
                    ),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(20.0),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ..._reminders,
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        child: Text('Add New Reminder'),
                        onPressed: _showAddReminderDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  ReminderCard({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.alarm),
          color: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class WaterReminderCard extends StatelessWidget {
  final String title;
  final bool switchOn;
  final ValueChanged<bool> onSwitchChanged;

  WaterReminderCard(
      {required this.title,
      required this.switchOn,
      required this.onSwitchChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        trailing: Switch(
          value: switchOn,
          onChanged: onSwitchChanged,
          activeColor: Colors.white,
        ),
      ),
    );
  }
}
