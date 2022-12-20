import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/soin.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';

class AddSoin extends StatefulWidget {
  final DateTime daySelected;

  const AddSoin({super.key, required this.daySelected});

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

  late Soin selectedSoin;

  @override
  void initState() {
    super.initState();
    soinsFuture = getListSoins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().format(widget.daySelected)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          //key: _formKey,
          child: Column(
            children: <Widget>[MyFuture(), MyButton()],
          ),
        ),
      ),
    );
  }

  Future<List<Soin>> getListSoins() async {
    db.collection('soins').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Soin soin = Soin(
            id: doc.id,
            nom: doc.get('nom'),
            prix: doc.get('prix'),
            date: widget.daySelected);
        services.add(soin);
      });
    });
    return Future.value(services);
  }

  ElevatedButton MyButton() {
    return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
          }
        },
        child: const Text('Save'));
  }

  FutureBuilder<List<Soin>> MyFuture() {
    return FutureBuilder<List<Soin>>(
        future: soinsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Erreur de connextion Internet');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Veuillez patienter");
          }
          services = snapshot.data!;
          return Form(
              key: _formKey,
              child: SearchField(
                suggestions: services
                    .map((soin) =>
                        SearchFieldListItem<Soin>(soin.nom, item: soin))
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
                  Soin soin = services.singleWhere((soin) => soin.nom == x);
                  if (x!.isEmpty || soin == null) {
                    return 'Entrez un soin valide';
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
              ));
        });
  }
}
