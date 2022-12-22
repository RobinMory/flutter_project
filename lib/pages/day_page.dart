import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/service.dart';
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
  final Stream<QuerySnapshot> services =
      FirebaseFirestore.instance.collection('services').snapshots();
  List<DocumentSnapshot> documents = [];

  TimeOfDay _time = TimeOfDay.now();

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
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: services,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Erreur de connextion Internet');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Veuillez patienter");
              }
              documents = snapshot.data!.docs;
              documents = documents.where((searchedService) {
                return searchedService.get('date').toString() ==
                    widget.daySelected.toString();
              }).toList();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  late Service service = Service(
                      id: documents[index].id,
                      date: documents[index].get('date'),
                      heure: documents[index].get('heure'),
                      clientId: documents[index].get('id_client'),
                      soinId: documents[index].get('id_soin'));
                  return ListTile(
                    key: ValueKey(service.id),
                    onTap: () async {},
                    title: Text(getHourFormat(service.heure)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {},
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Service service = Service(
              id: '',
              date: widget.daySelected.toString(),
              heure: TimeOfDay.now().toString(),
              soinId: '',
              clientId: '');
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddSoin(
                      daySelected: widget.daySelected, service: service)));
        },
        tooltip: 'Ajouter un soin',
        child: const Icon(Icons.add),
      ),
    );
  }

  String getHourFormat(String s) {
    String formattedTime = s.substring(s.indexOf('(') + 1, s.indexOf(')'));
    return formattedTime;
  }
}
