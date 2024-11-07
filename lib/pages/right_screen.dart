import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Event {
  String name;
  String description;
  DateTime deadline;
  bool showOnHomeScreen;
  bool isCompleted;

  Event({
    required this.name,
    required this.description,
    required this.deadline,
    this.showOnHomeScreen = false,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'showOnHomeScreen': showOnHomeScreen,
        'isCompleted': isCompleted,
      };

  static Event fromJson(Map<String, dynamic> json) => Event(
        name: json['name'],
        description: json['description'],
        deadline: DateTime.parse(json['deadline']),
        showOnHomeScreen: json['showOnHomeScreen'],
        isCompleted: json['isCompleted'],
      );
}

class RightScreen extends StatefulWidget {
  @override
  _RightScreenState createState() => _RightScreenState();
}

class _RightScreenState extends State<RightScreen> {
  List<Event> _events = [];
  Color selectedColor = Colors.white;
  Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadEvents();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      int? colorValue = prefs.getInt(prefsSelectedColor);
      if (colorValue != null) {
        selectedColor = Color(colorValue);
      }
      int? textColorValue = prefs.getInt(prefsTextColor);
      if (textColorValue != null) {
        textColor = Color(textColorValue);
      }
    });
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventList = prefs.getStringList('events') ?? [];
    setState(() {
      _events = eventList.map((e) => Event.fromJson(json.decode(e))).toList();
    });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventList = _events.map((e) => json.encode(e.toJson())).toList();
    prefs.setStringList('events', eventList);
  }

  void _scheduleAlarm(Event event) async {
    final alarmId = event.name.hashCode;

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: event.deadline,
      assetAudioPath: 'assets/alarm.mp3',
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      androidFullScreenIntent: true,
      notificationSettings: NotificationSettings(
        title: event.name,
        body: event.description,
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  void _cancelAlarm(Event event) async {
    final alarmId = event.name.hashCode;
    await Alarm.stop(alarmId);
  }

  void _addEvent(Event event) {
    setState(() {
      _events.add(event);
    });
    _scheduleAlarm(event);
    _saveEvents();
  }

  void _deleteEvent(Event event) {
    setState(() {
      _events.remove(event);
    });
    _cancelAlarm(event);
    _saveEvents();
  }

  void _toggleComplete(Event event) {
    setState(() {
      event.isCompleted = !event.isCompleted;
    });
    _saveEvents();
  }

  String _formatDate(DateTime deadline) {
    final now = DateTime.now();
    if (deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day) {
      return 'Today, ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}';
    } else {
      return '${deadline.month}/${deadline.day}/${deadline.year}, ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showAddEventDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String description = '';
        DateTime deadline = DateTime.now();
        bool showOnHomeScreen = false;

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  labelStyle: TextStyle(
                    color: textColor,
                    fontFamily: fontNormal,
                  ),
                ),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    color: textColor,
                    fontFamily: fontNormal,
                  ),
                ),
                onChanged: (value) => description = value,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Deadline: ${deadline.month}/${deadline.day}/${deadline.year}, ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: fontNormal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: textColor),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        deadline = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          deadline.hour,
                          deadline.minute,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time, color: textColor),
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(deadline),
                      );
                      if (selectedTime != null) {
                        deadline = DateTime(
                          deadline.year,
                          deadline.month,
                          deadline.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Show on Home Screen',
                    style: TextStyle(
                      color: textColor,
                      fontFamily: fontNormal,
                    ),
                  ),
                  Switch(
                    value: showOnHomeScreen,
                    onChanged: (value) => setState(() {
                      showOnHomeScreen = value;
                    }),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  final newEvent = Event(
                    name: name,
                    description: description,
                    deadline: deadline,
                    showOnHomeScreen: showOnHomeScreen,
                  );
                  _addEvent(newEvent);
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(selectedColor),
                  backgroundColor: WidgetStatePropertyAll(textColor),
                ),
                child: Text(
                  'Add Event',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: fontNormal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedColor,
      appBar: AppBar(
        backgroundColor: selectedColor,
        title: Text(
          'Events',
          style: TextStyle(
            color: textColor,
            fontFamily: fontNormal,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(
              event.name,
              style: TextStyle(
                color: textColor,
                fontFamily: fontNormal,
              ),
            ),
            subtitle: Text(
              _formatDate(event.deadline),
              style: TextStyle(
                color: textColor,
                fontFamily: fontNormal,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: event.isCompleted
                        ? Colors.green[300]
                        : Colors.grey[500],
                  ),
                  onPressed: () => _toggleComplete(event),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[300]),
                  onPressed: () => _deleteEvent(event),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Text(
          'Add Event',
          style: TextStyle(
            color: textColor,
            fontFamily: fontNormal,
          ),
        ),
      ),
    );
  }
}
