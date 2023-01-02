import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatPage extends StatefulWidget {
  final String title;

  const StatPage({super.key, required this.title});

  @override
  StatPageState createState() {
    return StatPageState();
  }
}

class StatPageState extends State<StatPage> {

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
              modeButton("Meilleur client :", "Client 3", Icons.list, width),
              modeButton("Soin le plus demandé :", "Soin des mains", Icons.calendar_today, width),
              modeButton("Recette du mois/année :", "3500 €", Icons.numbers, width)
            ],
          ) 
            ]
            ),
          ),
        ),
        )
      );
  }
  
  modeButton(String titre, String sousTitre, IconData icon, double width) {
    return GestureDetector(
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
                    )
                  ]
                ),
            ),
             Padding(padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 80,),
             child: Icon(icon, color : Colors.white,),
             )
          ],
        ),
      ),
    );
  }
}

