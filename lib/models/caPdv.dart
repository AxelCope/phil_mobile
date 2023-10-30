
import 'package:phil_mobile/provider/db_constant.dart';

class ChiffreAffaire
{
   double? chiffreAffaire;
   int? obj;
   int? comm;

   ChiffreAffaire({
   this.chiffreAffaire,
   this.obj,
   this.comm,
});

   factory ChiffreAffaire.MapChiffresaffaire(Map<String, dynamic> map) {
     return ChiffreAffaire(
       chiffreAffaire: double.parse(map[dbSomme]),
     );
   }
   factory ChiffreAffaire.MapObj(Map<String, dynamic> map) {
     return ChiffreAffaire(
       obj: map[dbSomme],
     );
   }
 factory ChiffreAffaire.MapComm(Map<String, dynamic> map) {
     return ChiffreAffaire(
       comm: map[dbSomme],
     );
   }

}