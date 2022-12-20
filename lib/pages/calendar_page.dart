import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/pages/day_page.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {

  final String title;

  const CalendarPage({super.key, required this.title});

  @override
  CalendarPageState createState() {
    return CalendarPageState();
  }
}

class CalendarPageState extends State<CalendarPage> {

  DateTime today = DateTime.now();
  var db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body : monCalendrier(),
    );
  }
  
  Widget monCalendrier() {
    return TableCalendar(
      focusedDay: today,
      firstDay: DateTime.utc(2020,01,01),
      lastDay: DateTime.utc(2030,01,01),
      //locale: 'fr',
      rowHeight: 60,
      headerStyle: 
      const HeaderStyle(formatButtonVisible: false,titleCentered: true),
      availableGestures: AvailableGestures.all,
      onDaySelected: _onDaySelected,
    );
  }

  

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    await Navigator.push(context,MaterialPageRoute(builder: (context) => DayPage(daySelected: selectedDay)));
  }
}