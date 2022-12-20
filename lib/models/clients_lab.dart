import 'package:flutter_project/models/client.dart';

class ClientsLab {

  static final ClientsLab _current = ClientsLab._privateConstructor();

  factory ClientsLab() => _current; 
  ClientsLab._privateConstructor();

  final List<Client> _clients = [];

  List<Client> get clients => _clients;

  void addCrime(Client client) {
    _clients.add(client);
  }

  void removeCrime(Client client) {
    _clients.remove(client);
  }
}