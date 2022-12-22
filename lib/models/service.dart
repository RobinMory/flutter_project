import 'package:flutter/material.dart';

class Service {

  final String id;
  final String clientId;
  final String soinId;
  String date;
  String heure;

  Service({
    required this.id,
    required this.date,
    required this.clientId,
    required this.soinId,
    required this.heure,
  });

  String getId() {
    return id;
  }
}