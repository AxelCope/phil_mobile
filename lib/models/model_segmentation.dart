
import 'package:phil_mobile/provider/db_constant.dart';

class Segmentation{
  String? nomPoints;
  int? id;
  double? somme;
  int? objectifs;
  int? commissions;

  Segmentation({
    this.id,
    this.somme,
    this.nomPoints,
    this.objectifs,
    this.commissions
  });

  factory Segmentation.mapSegmentation(Map<String, dynamic> map) {
    return Segmentation(
        nomPoints: map[dbName],
        id: map[dbId],
        somme:  double.parse(map[dbSommeDotes])
    );
  }

  factory Segmentation.MapPoint(Map<String, dynamic> map) {
    return Segmentation(
        somme:  double.parse(map[dbSomme])
    );
  }
  factory Segmentation.objectifsComm(Map<String, dynamic> map) {
    return Segmentation(
        objectifs:  map[dbObj]
    );
  }
  factory Segmentation.commissionCommerciaux(Map<String, dynamic> map) {
    return Segmentation(
        commissions:   map[dbSomme]
    );
  }
}