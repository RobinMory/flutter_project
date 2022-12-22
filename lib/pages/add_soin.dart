import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/client.dart';
import 'package:flutter_project/models/service.dart';
import 'package:flutter_project/models/soin.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';

class AddSoin extends StatefulWidget {
  final DateTime daySelected;
  final Service service;

  const AddSoin({super.key, required this.daySelected, required this.service});

  @override
  AddSoinState createState() {
    return AddSoinState();
  }
}

class AddSoinState extends State<AddSoin> {
  final _formKey = GlobalKey<FormState>();

  var db = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> soins =
      FirebaseFirestore.instance.collection('soins').snapshots();

  final soinsSelect = TextEditingController();

  List<Soin> services = [];
  late Future<List<Soin>> soinsFuture;
  List<Client> clients = [];
  late Future<List<Client>> clientsFuture;

  late Soin selectedSoin;
  late Client selectedClient;

  TimeOfDay _time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    soinsFuture = getListSoins();
    clientsFuture = getListClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(DateFormat.yMMMd().format(widget.daySelected)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              key: _formKey,
              children: <Widget>[
                MySearchFieldSoin(),
                MySearchFieldClient(),
                MyHourPicker(),
                MyButton()
              ],
            ),
          ),
        ));
  }

  FutureBuilder<List<Soin>> MySearchFieldSoin() {
    return FutureBuilder<List<Soin>>(
        future: soinsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Erreur de connextion Internet');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          services = snapshot.data!;
          return SearchField(
            suggestions: services
                .map((soin) => SearchFieldListItem<Soin>(soin.nom, item: soin))
                .toList(),
            suggestionState: Suggestion.expand,
            textInputAction: TextInputAction.next,
            hint: 'Choisissez un soin',
            hasOverlay: false,
            searchStyle: TextStyle(
              fontSize: 18,
              color: Colors.black.withOpacity(0.8),
            ),
            validator: (x) {
              if (x!.isEmpty) {
                return 'Entrez un soin';
              }
              return null;
            },
            searchInputDecoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            maxSuggestionsInViewPort: 6,
            itemHeight: 50,
            onSuggestionTap: (soin) {
              selectedSoin = soin.item!;
            },
          );
        });
  }

  FutureBuilder<List<Client>> MySearchFieldClient() {
    return FutureBuilder<List<Client>>(
        future: clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Erreur de connextion Internet');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Veuillez patienter");
          }
          clients = snapshot.data!;
          return SearchField(
            suggestions: clients
                .map((client) => SearchFieldListItem<Client>(
                    "${client.nom} ${client.prenom}",
                    item: client))
                .toList(),
            suggestionState: Suggestion.expand,
            textInputAction: TextInputAction.next,
            hint: 'Choisissez un client',
            hasOverlay: false,
            searchStyle: TextStyle(
              fontSize: 18,
              color: Colors.black.withOpacity(0.8),
            ),
            validator: (x) {
              if (x!.isEmpty) {
                return 'Entrez un client';
              }
              return null;
            },
            searchInputDecoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            maxSuggestionsInViewPort: 6,
            itemHeight: 50,
            onSuggestionTap: (client) {
              selectedClient = client.item!;
            },
          );
        });
  }

  ElevatedButton MyButton() {
    return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            Map<String, String> service = {
              'date': widget.daySelected.toString(),
              'heure': _time.toString(),
              'id_client' : selectedClient.id,
              'id_soin' : selectedSoin.id,
            };
            if (widget.service.getId() == '') {
              db.collection('services').add(service);
            } else {
              db
                  .collection('services')
                  .doc(widget.service.getId())
                  .update(service);
            }
            Navigator.pop(context);
          }
        },
        child: const Text('Save'));
  }

  ElevatedButton MyHourPicker() {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(showPicker(
            value: _time,
            hourLabel: "heures",
            is24HrFormat: true,
            iosStylePicker: true,
            onChange: (TimeOfDay time) {
              setState(() {
                _time = time;
              });
            },
          ));
        },
        child: Text(getHourFormat(_time)));
  }

  Future<List<Client>> getListClients() async {
    clients = [];
    final snapshot = await db.collection('clients').get();
    for (var doc in snapshot.docs) {
      Client client = Client(
          id: doc.id,
          nom: doc.get('nom'),
          prenom: doc.get('prenom'),
          numero: doc.get('numero'));
      clients.add(client);
    }
    return clients;
  }

  Future<List<Soin>> getListSoins() async {
    services = [];
    final snapshot = await db.collection('soins').get();
    for (var doc in snapshot.docs) {
      Soin soin = Soin(
          id: doc.id,
          nom: doc.get('nom'),
          prix: doc.get('prix'),
          date: widget.daySelected);
      services.add(soin);
    }
    return services;
  }

  String getHourFormat(TimeOfDay time) {
    var replacingTime = time.replacing(hour: time.hour, minute: time.minute);
    String formattedTime = "${replacingTime.hour}:${replacingTime.minute}";
    return formattedTime;
  }
}
