import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/models/client.dart';

import 'clients_events.dart';
import 'clients_states.dart';

class ClientsBloc extends Bloc<ClientEvent, ClientsState> {
  ClientsBloc(List<Client> clients) : super(ClientsState(clients)) {
    on <AddClientEvent>((event, emit) {
      List<Client> clients = List.from(state.clients);
      clients.add(event.client);
      emit(ClientsState(clients));
    });
    on<RemoveClientEvent>((event, emit) {
      List<Client> clients = List.from(state.clients);
      clients.remove(event.client);
      emit(ClientsState(clients));
    });
    on<UpdateClientEvent>((event, emit) {
      emit(ClientsState(state.clients));
    });
  }
}
