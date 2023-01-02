import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/client.dart';
import 'package:flutter_project/pages/client_editor.dart';

class ClientListView extends StatefulWidget {
  const ClientListView({super.key});

  @override
  State<ClientListView> createState() => _ClientsListViewState();
}

class _ClientsListViewState extends State<ClientListView> {
  final Stream<QuerySnapshot> clients =
      FirebaseFirestore.instance.collection('clients').snapshots();
  late DocumentReference ref;
  var db = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  List<DocumentSnapshot> documents = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Recherche...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: clients,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Erreur de connextion Internet');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Veuillez patienter");
            }
            documents = snapshot.data!.docs;
            if (searchText.isNotEmpty) {
              documents = documents.where((searchedClient) {
                return searchedClient
                        .get('nom')
                        .toString()
                        .toLowerCase()
                        .contains(searchText.toLowerCase()) ||
                    searchedClient
                        .get('prenom')
                        .toString()
                        .toLowerCase()
                        .contains(searchText.toLowerCase());
              }).toList();
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                late Client client = Client(
                    id: documents[index].id,
                    nom: documents[index].get('nom'),
                    prenom: documents[index].get('prenom'),
                    numero: documents[index].get('numero'));
                return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blueGrey[100],
                    ),
                    child: ListTile(
                      key: ValueKey(client.id),
                      leading: const Icon(
                        Icons.account_circle,
                        size: 50,
                      ),
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ClientEditor(client: client)));
                      },
                      title: Text('${client.nom} ${client.prenom}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showAlertDialog(context, client);
                        },
                      ),
                    ));
              },
            );
          },
        )
      ],
    );
  }

  showAlertDialog(BuildContext context, Client client) {
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
        ref = db.collection('clients').doc(client.id);
        ref.delete();
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Supprimer le client"),
      content: Text("Voulez-vous supprimer "
          '${client.nom} ${client.prenom}'
          " de la liste des clients ?"),
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
