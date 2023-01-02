import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/service.dart';
import 'package:flutter_project/pages/service_editor.dart';
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
  late final List<String> toHighlight = [];

  DateTime _daySelected = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  late DocumentReference ref;

  var db = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> services =
      FirebaseFirestore.instance.collection('services').snapshots();
  List<DocumentSnapshot> documents = [];

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
      body: Column(
        children: [
          monCalendrier(),
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
                return searchedService.get('date') == _daySelected.toString();
              }).toList();
              documents.sort((a, b) => a.get('heure').compareTo(b.get('heure')));
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
                  return getListTile(service);
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
              date: _daySelected.toString(),
              heure: TimeOfDay.now().toString(),
              soinId: '',
              clientId: '');
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ServiceEditor(daySelected: _daySelected, service: service)));
        },
        tooltip: 'Ajouter un soin',
        child: const Icon(Icons.add),
        
      ),
    );
  }

  Widget monCalendrier() {
    return FutureBuilder<List<String>>(
      future: getListDateToHighLight(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                //child: CircularProgressIndicator(),
                );
          } else {
            return TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2022),
                lastDay: DateTime.utc(2025),
                //locale: 'fr_FR',
                rowHeight: 50,
                headerStyle: const HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) {
                  return isSameDay(_daySelected, day);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                onDaySelected: ((selectedDay, focusedDay) => {
                      setState(() {
                        _daySelected = selectedDay;
                        _focusedDay = focusedDay;
                      })
                    }),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    for (String d in toHighlight) {
                      if (day.toString() == d) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    }
                    return null;
                  },
                ));
          }
        } else if (snapshot.hasError) {
          return const Text('no data');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  getListTile(Service service) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getTextInfo(service.soinId, service.clientId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                //child: CircularProgressIndicator(),
                );
          } else {
            Map<String, dynamic> myMap = Map.from(snapshot.data!);
            return Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blueGrey[100],
                    ),
                    child: ListTile(
              key: ValueKey(service.id),
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServiceEditor(
                            daySelected: _daySelected, service: service)));
              },
              // ignore: prefer_interpolation_to_compose_strings
              title: Text('${service.heure}      ' + myMap['nomSoin'] + ' à ' + myMap['prixSoin'].toString() + '€'),
              subtitle: Text(myMap['nomClient'] + ' ' + myMap['prenomClient']),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showAlertDialog(context, service);
                },
              ),
            ));
          }
        } else if (snapshot.hasError) {
          return const Text('no data');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  String getHourFormat(String s) {
    String formattedTime = s.substring(s.indexOf('(') + 1, s.indexOf(')'));
    return formattedTime;
  }

  Future<List<String>> getListDateToHighLight() async {
    final snapshot = await db.collection('services').get();
    for (var doc in snapshot.docs) {
      toHighlight.add(doc.get('date'));
    }
    return toHighlight;
  }

  Future<Map<String, dynamic>> getTextInfo(
      String soinId, String clientId) async {
    String nomSoin = '';
    int prixSoin = 0;
    await db
        .collection("soins")
        .doc(soinId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        nomSoin = documentSnapshot.get('nom');
        prixSoin = documentSnapshot.get('prix');
      }
    });
    String nomClient = '';
    String prenomClient = '';
    await db
        .collection("clients")
        .doc(clientId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        nomClient = documentSnapshot.get('nom');
        prenomClient = documentSnapshot.get('prenom');
      }
    });
    Map<String, dynamic> infoService = {
      'nomSoin': nomSoin,
      'nomClient': nomClient,
      'prenomClient': prenomClient,
      'prixSoin': prixSoin
    };
    return infoService;
  }

  showAlertDialog(BuildContext context, Service service) {
    Widget cancelButton = ElevatedButton(
      child: const Text("Annuler"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Confirmer"),
      onPressed: () {
        Navigator.of(context).pop();
        ref = db.collection('services').doc(service.id);
        ref.delete();
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Supprimer le soin"),
      content: const Text("Voulez-vous supprimer ce soin ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
 
}
