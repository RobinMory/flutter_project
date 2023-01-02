import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/client.dart';
import 'package:flutter_project/models/service.dart';
import 'package:intl/intl.dart';

class ClientEditor extends StatefulWidget {
  final Client client;

  const ClientEditor({super.key, required this.client});

  @override
  ClientEditorState createState() {
    return ClientEditorState();
  }
}

class ClientEditorState extends State<ClientEditor> {
  final _formKey = GlobalKey<FormState>();

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
        title: Text('${widget.client.nom} ${widget.client.prenom}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                  initialValue: widget.client.nom,
                  decoration: const InputDecoration(
                      hintText: 'Entrer un nom',
                      labelText: 'Nom',
                      icon: Icon(Icons.abc)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    widget.client.nom = value!;
                  }),
              TextFormField(
                  initialValue: widget.client.prenom,
                  decoration: const InputDecoration(
                      hintText: 'Enter un prénom',
                      labelText: 'Prénom',
                      icon: Icon(Icons.abc)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prénom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    widget.client.prenom = value!;
                  }),
              TextFormField(
                  initialValue: widget.client.numero,
                  decoration: const InputDecoration(
                      hintText: 'Enter un numéro de téléphone',
                      labelText: 'Numéro de téléphone',
                      icon: Icon(Icons.numbers)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un numéro de téléphone';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    widget.client.numero = value!;
                  }),
              Padding(padding: const EdgeInsets.all(18),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Map<String, String> client = {
                      'nom': widget.client.nom,
                      'prenom': widget.client.prenom,
                      'numero': widget.client.numero,
                    };
                    if (widget.client.getId() == '') {
                      db.collection('clients').add(client);
                    } else {
                      db
                          .collection('clients')
                          .doc(widget.client.getId())
                          .update(client);
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
                child: const Text('Sauver'),
              ),),
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
                    return searchedService.get('id_client').toString() ==
                        widget.client.getId().toString();
                  }).toList();
                  documents.sort((a, b) {
                    return a.get('heure').compareTo(b.get('heure'));
                  });
                  documents.sort((a, b) {
                    return a.get('date').compareTo(b.get('date'));
                  });
                  if (documents.isEmpty) {
                    return const Center(child: Text("Aucun service"));
                  } else {
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
                  }
                },
              )
            ],
          ),
        ),
      ),
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
            return Container ( 
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueGrey[100],
              ),
              child :ListTile(
              key: ValueKey(service.id),
              onTap: () {},
              // ignore: prefer_interpolation_to_compose_strings
              title: Text('${service.heure}     ' + myMap['nomSoin']),
              subtitle: Text(getDateFormat(service.date)),
            ));
          }
        } else if (snapshot.hasError) {
          return const Text('no data');
        }
        return const CircularProgressIndicator();
      },
    );
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

  String getDateFormat(String s) {
    DateTime date = DateTime.parse(s);
    return DateFormat.yMMMMEEEEd().format(date);
  }
}
