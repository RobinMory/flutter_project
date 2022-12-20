import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_soin.dart';

class DayPage extends StatefulWidget {

  final DateTime daySelected;


  const DayPage({super.key, required this.daySelected});

  @override
  DayPageState createState() {
    return DayPageState();
  }
}

class DayPageState extends State<DayPage> {

  var db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().format(widget.daySelected)),
      ),
      body: Column(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
              await Navigator.push(context,MaterialPageRoute(builder: (context) => AddSoin(daySelected: widget.daySelected)));
            },
          tooltip: 'Ajouter un soin',
          child: const Icon(Icons.add),
        ),
    );
  }
  }
