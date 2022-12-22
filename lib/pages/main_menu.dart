import 'package:flutter/material.dart';
import 'package:flutter_project/pages/calendar_page.dart';
import 'package:flutter_project/pages/client_list.dart';
import 'package:flutter_project/pages/statpage.dart';

class MainMenu extends StatefulWidget {

  final String title;

  const MainMenu({super.key, required this.title});

  @override
  State<MainMenu> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenu> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: Text(widget.title)
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(8.0),
              color: Colors.red,
              child:ElevatedButton(
                onPressed:  () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => const ClientList(title: 'Liste clients')));
              setState(() {});
            },
                child: const Text('Liste clients'),
              ),
            ),
          ),
          Flexible(
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(8.0),
              color: Colors.red,
              child:ElevatedButton(
                onPressed:  () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => const CalendarPage(title: 'Calendrier')));
              setState(() {});
            },
                child: const Text('Calendrier'),
              ),
            ),
          ),
          Flexible(
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(8.0),
              color: Colors.red,
              child:ElevatedButton(
                onPressed:  () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => const StatPage(title: 'Statistiques')));
              setState(() {});
            },
                child: const Text('Statistiques'),
              ), 
            ),
          ),
        ],
      ),
      );
  }
}





