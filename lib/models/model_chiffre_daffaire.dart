
import 'package:phil_mobile/provider/db_constant.dart';

class ChiffreAffaire
{
   double? chiffreAffaire;
   int? solde;
   int? obj;
   String? comm;
   String? date;

   ChiffreAffaire({
   this.chiffreAffaire,
     this.solde,
   this.obj,
   this.comm,
     this.date
});

   factory ChiffreAffaire.MapChiffresaffaire(Map<String, dynamic> map) {
     return ChiffreAffaire(
       chiffreAffaire: double.parse(map[dbSomme]),
     );
   }

   factory ChiffreAffaire.MapCommbyMonth(Map<String, dynamic> map) {
     return ChiffreAffaire(
       chiffreAffaire: double.parse(map[dbSomme]),
       date: map[dbMonth],
     );
   }


   factory ChiffreAffaire.MapObj(Map<String, dynamic> map) {
     return ChiffreAffaire(
       obj: map[dbSomme],
     );
   }

   factory ChiffreAffaire.MapSolde(Map<String, dynamic> map) {
     return ChiffreAffaire(
       solde: map[dbSolde],
     );
   }


 factory ChiffreAffaire.MapComm(Map<String, dynamic> map) {
     return ChiffreAffaire(
       comm: map[dbSomme],
     );
   }

}