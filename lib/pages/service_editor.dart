import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/client.dart';
import 'package:flutter_project/models/service.dart';
import 'package:flutter_project/models/soin.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';

class ServiceEditor extends StatefulWidget {
  final DateTime daySelected;
  final Service service;

  const ServiceEditor(
      {super.key, required this.daySelected, required this.service});

  @override
  ServiceEditorState createState() {
    return ServiceEditorState();
  }
}

class ServiceEditorState extends State<ServiceEditor> {
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

  SearchFieldListItem<Client>? _clientSelect;
  SearchFieldListItem<Soin>? _soinSelect;

  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    soinsFuture = getListSoins();
    clientsFuture = getListClients();
    _time = getTimeValue();
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    mysearchfieldsoin(),
                    const SizedBox(
                      height: 30,
                    ),
                    mysearchfieldclient(),
                    const SizedBox(
                      height: 30,
                    ),
                    myhourpicker(),
                    mybutton()
                  ],
                ),
              ),
            )));
  }

  FutureBuilder<List<Soin>> mysearchfieldsoin() {
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
            initialValue: getSelectedSoin(),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un soin';
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

  FutureBuilder<List<Client>> mysearchfieldclient() {
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
            initialValue: getSelectedClient(),
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
              if (x == null || x.isEmpty) {
                return 'Veuillez entrer un client';
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
              FocusScope.of(context).unfocus();
            },
          );
        });
  }

  Padding mybutton() {
    return Padding(padding: const EdgeInsets.all(18),
    child :ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            Map<String, String> service = {
              'date': widget.daySelected.toString(),
              'heure': getFirebaseHourFormat(_time),
              'id_client': selectedClient.id,
              'id_soin': selectedSoin.id,
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
        style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, padding: const EdgeInsets.all(18), backgroundColor: Colors.lightBlue[400],
                  shadowColor: Colors.black,
                  fixedSize: const Size(300,65),
                  textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
        child: const Text('Sauver')
        ),
      );
  }

  ElevatedButton myhourpicker() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.access_time_outlined),
      label : getHourFormat(_time),
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
        style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, padding: const EdgeInsets.all(18), backgroundColor: Colors.lightBlue[400],
                  shadowColor: Colors.black,
                  fixedSize: const Size(300,65),
                  textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
    ),
    );
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
      if (widget.service.clientId == client.id) {
        selectedClient = client;
        _clientSelect = SearchFieldListItem<Client>(
            "${client.nom} ${client.prenom}",
            item: client);
      }
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
      if (widget.service.soinId == soin.id) {
        selectedSoin = soin;
        _soinSelect = SearchFieldListItem<Soin>(soin.nom, item: soin);
      }
    }
    return services;
  }

  String getFirebaseHourFormat(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, "0");
    final min = time.minute.toString().padLeft(2, "0");
    return "$hour:$min";
  }

  Text getHourFormat(TimeOfDay timeVariable) {
    final hour = timeVariable.hour.toString().padLeft(2, "0");
    final min = timeVariable.minute.toString().padLeft(2, "0");
    return  Text("$hour:$min");
  }

  getSelectedSoin() {
    if (_soinSelect != null) {
      return _soinSelect;
    }
    return null;
  }

  getSelectedClient() {
    if (_clientSelect != null) {
      return _clientSelect;
    }
    return null;
  }
  
  TimeOfDay getTimeValue() {
    if (widget.service.getId() != '') {
     String s = widget.service.getHeure();
     return TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
    }
    return TimeOfDay.now();
  }
}
