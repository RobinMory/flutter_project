import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/client.dart';
import 'package:flutter_project/models/service.dart';

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
              ElevatedButton(
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
                child: const Text('Save'),
              ),
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
                  if(documents.length == 0) {
                    return const Text("Aucun service");
                  }else{
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
                      );
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

   String getHourFormat(String s) {
    String formattedTime = s.substring(s.indexOf('(') + 1, s.indexOf(')'));
    return formattedTime;
  }

  String getDateFormat(String s) {
    String formattedDate = s.substring(s.indexOf('[') + 1, s.indexOf(']'));
    return formattedDate;
  }
}
