import 'package:flutter/material.dart';
import 'package:flutter_project/pages/caldendar_page.dart';
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
    double width =  MediaQuery.of(context).size.width - 80;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0,40,0,20),
            child: Column(children: [
              Wrap(
            runSpacing: 30,
            children: [
              modeButton("Liste clients", "Informations sur les clients", Icons.list, width,1),
              modeButton("Calendrier", "Voir les rendez-vous", Icons.calendar_today, width,2),
              modeButton("Statitisques", "Voir les statistiques", Icons.numbers, width,3)
            ],
          ) 
            ]
            ),
          ),
        ),
        )
      );
  }
  
  modeButton(String titre, String sousTitre, IconData icon, double width , int route) {
    return GestureDetector(
      onTap: () => {
        getRouteInfo(route)
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          fontFamily: 'Manrope',
                          color: Colors.white,
                          fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        sousTitre,
                        style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontFamily: 'Manrope',
                            fontSize: 14),
                      ),
                    ),
                  ]
                ),
            ),
             Padding(padding: const EdgeInsets.symmetric(horizontal: 57,vertical: 80,),
             child: Icon(icon, color : Colors.white,),
             )
          ],
        ),
      ),
    );
  }
  
  getRouteInfo(int route) {
     switch(route){
          case 1 : Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientList(title:"Liste clients")));
          break;
          case 2 : Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage(title:"Calendrier")));
          break;
          case 3 : Navigator.push(context, MaterialPageRoute(builder: (context) => const StatPage(title: "Statistiques")));
          break;
        }
  }
}