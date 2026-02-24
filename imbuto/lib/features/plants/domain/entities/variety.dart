import 'package:equatable/equatable.dart';

class Variety extends Equatable {
  final int id;
  final int plantId;
  final String plantName;
  final String nom;
  final String? nomBotanique;
  final String? nomVariete;
  final String? nomKirundi;
  final String? photo;
  final String? codeOrigine;
  final String? centreOrigine;
  final String? obtenteur;
  final String? mainteneur;
  final int? anneeDiffusion;
  final DateTime? dateInscription;
  final String? numeroEnregistrement;
  final String? serviceExamen;
  final String? stationExamen;
  final String? periodeExamen;
  final String? zoneCulture;
  final String? rendement;
  final String? cycleVegetatif;
  final DateTime createdAt;

  const Variety({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.nom,
    this.nomBotanique,
    this.nomVariete,
    this.nomKirundi,
    this.photo,
    this.codeOrigine,
    this.centreOrigine,
    this.obtenteur,
    this.mainteneur,
    this.anneeDiffusion,
    this.dateInscription,
    this.numeroEnregistrement,
    this.serviceExamen,
    this.stationExamen,
    this.periodeExamen,
    this.zoneCulture,
    this.rendement,
    this.cycleVegetatif,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, plantId, plantName, nom, nomBotanique, nomVariete, nomKirundi,
    photo, codeOrigine, centreOrigine, obtenteur, mainteneur, anneeDiffusion,
    dateInscription, numeroEnregistrement, serviceExamen, stationExamen,
    periodeExamen, zoneCulture, rendement, cycleVegetatif, createdAt,
  ];
}
