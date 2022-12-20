import 'package:flutter_project/models/client.dart';

class ClientEvent {}

class AddClientEvent extends ClientEvent {
  final Client client;

  AddClientEvent(this.client);
}

class RemoveClientEvent extends ClientEvent {
   final Client client;

  RemoveClientEvent(this.client);
}

class UpdateClientEvent extends ClientEvent {
   final Client client;

  UpdateClientEvent(this.client);
}
