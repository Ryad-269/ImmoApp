


class Property {
  final int id;
  final String titre;
  final String description;
  final int prix;
  final String district;
  final int chambres;
  final int? superficie;
  final String? photo;
  final String statut;
  final DateTime createdAt;
  final String proprietaireNom;

  Property({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.district,
    required this.chambres,
    this.superficie,
    this.photo,
    required this.statut,
    required this.createdAt,
    required this.proprietaireNom,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      prix: json['prix'],
      district: json['district'],
      chambres: json['chambres'],
      superficie: json['superficie'],
      photo: json['photo'],
      statut: json['statut'],
      createdAt: DateTime.parse(json['created_at']),
      proprietaireNom: json['proprietaire_nom'] ?? '',
    );
  }
}