import 'package:flutter/material.dart';
import 'package:flutter_project/models/client.dart';
import 'package:flutter_project/pages/client_editor.dart';
import 'package:flutter_project/pages/client_list_view.dart';

class ClientList extends StatefulWidget {
  final String title;

  const ClientList({super.key, required this.title});

  @override
  State<ClientList> createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const ClientListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Client client = Client(id: '', nom: '', prenom: '', numero: '');
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClientEditor(client: client)));
            },
          tooltip: 'Ajouter un client',
          child: const Icon(Icons.add),
        ),
      );
  }
}

/*

// ignore: must_be_immutable
class ClientListView extends StatelessWidget {

  ClientListView({super.key});

  final Stream<QuerySnapshot> clients = FirebaseFirestore.instance.collection('clients').snapshots();

  late DocumentReference ref;
  var db = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
        TextField(
        controller: _searchController,
        onChanged: (value) {
        //setState(() {searchText = value;});
      },
        decoration: const InputDecoration(
        hintText: 'Recherhce...',
        prefixIcon: Icon(Icons.search),
  ),
),
        StreamBuilder<QuerySnapshot>(
        stream: clients,
        builder :(
          context,
          AsyncSnapshot<QuerySnapshot> snapshot)
        {
          if (snapshot.hasError) {
            return const Text('Erreur de connextion Internet');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Veuillez patienter");
          }
          final clients = snapshot.requireData;

          return ListView.builder(
          itemCount: clients.size,
          itemBuilder: (context, index) {
            late Client client = Client(
              id: clients.docs[index].id,
              nom: clients.docs[index].get('nom'),
              prenom: clients.docs[index].get('prenom'),
              numero: clients.docs[index].get('numero'));
            return ListTile(
            onTap: () async {
              await Navigator.push(context,MaterialPageRoute(builder: (context) => ClientEditor(client: client)));
            },
            title: Text('${client.nom} ${client.prenom}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showAlertDialog(context, client);
              },
            ),
          );
          },
          );
          },
        )
    ],
    );  
  }

  showAlertDialog(BuildContext context,Client client) {
  Widget cancelButton = ElevatedButton(
    child: const Text("Annuler"),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = ElevatedButton(
    child: const Text("Confirmer"),
    onPressed:  () {
      Navigator.of(context).pop();
      ref = db.collection('clients').doc(client.id);
      ref.delete();
      },
  );
  AlertDialog alert = AlertDialog(
    title: const Text("Supprimer le client"),
    content: Text("Voulez-vous supprimer "'${client.nom} ${client.prenom}'" de la liste des clients ?"),
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
*/

