import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatPage extends StatefulWidget {
  final String title;

  const StatPage({super.key, required this.title});

  @override
  StatPageState createState() {
    return StatPageState();
  }
}

class StatPageState extends State<StatPage> {
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
        body: Center(
            child: Column(
          children: [
            const Text(
              "Client le plus actif",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Soin le plus demandé",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Recette du mois",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        )));
  }
}
