import 'package:phil_mobile/provider/db_constant.dart';

class GiveCom
{
  int? montant;
  int? numero;
  String? pdvs;

  GiveCom({
    this.montant,
    this.pdvs,
    this.numero
});

  factory GiveCom.mapGivecom(Map<String, dynamic> map)
  {
    return GiveCom(
      montant: map[dbSomme],
      numero: map[dbnumero],
      pdvs: map[dbPdvs]
    );
  }

}