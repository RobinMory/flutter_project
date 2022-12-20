class Client {

  final String id;
  String nom;
  String prenom;
  String numero;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.numero,
  });

  String getId() {
    return id;
  }
}