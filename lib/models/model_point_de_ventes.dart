import 'package:flutter/cupertino.dart';
import 'package:phil_mobile/provider/db_constant.dart';

class PointDeVente {
   int? numeroFlooz;
   String? nomDuPoint;
   String? profil;
   String? typeDactivite;
   String? localisation;
   String? region;
   String? prefecture;
   String? commune;
   String? canton;
   String? quartier;
   String? latitude;
   String? longitude;
   String? numeroProprietaireDuPdv;
   String? autreContactDuPdv;
   String? sexeDuGerant;
   String? nif;
   String? regimeFiscal;
   String? supportDeVisibiliteChevaletPotenceAutocollant;
   String? etatDuSupportDeVisibiliteBonMauvais;
   int? numeroCagnt;
   String? commercial;
   int? dotee;
   bool checked;
   TextEditingController comment;

  PointDeVente({
     this.numeroFlooz,
     this.nomDuPoint,
     this.profil,
     this.typeDactivite,
     this.localisation,
     this.region,
     this.prefecture,
     this.commune,
     this.canton,
     this.quartier,
     this.latitude,
     this.longitude,
     this.numeroProprietaireDuPdv,
     this.autreContactDuPdv,
     this.sexeDuGerant,
     this.nif,
     this.regimeFiscal,
     this.supportDeVisibiliteChevaletPotenceAutocollant,
     this.etatDuSupportDeVisibiliteBonMauvais,
     this.numeroCagnt,
     this.commercial,
     this.dotee,
     this.checked = false,
  }): comment = TextEditingController();


   factory PointDeVente.MapPdvs(Map<String, dynamic> map) { 
     return PointDeVente(
         numeroFlooz: map[dbnumeroFlooz],
         nomDuPoint: map[dbnomDuPoint],
         profil: map[dbprofil],
         typeDactivite: map[dbtypeDactivite],
         localisation: map[dblocalisation],
         region: map[dbregion],
         prefecture: map[dbprefecture],
         commune: map[dbcommune],
         canton: map[dbcanton],
         quartier: map[dbquartier],
         latitude: map[dblatitude],
         longitude: map[dblongitude],
         numeroProprietaireDuPdv: map[dbnumeroProprietaireDuPdv],
         autreContactDuPdv: map[dbautreContactDuPdv],
         sexeDuGerant: map[dbsexeDuGerant],
         nif: map[dbnif],
         regimeFiscal: map[dbregimeFiscal],
         supportDeVisibiliteChevaletPotenceAutocollant: map[dbsupportDeVisibiliteChevaletPotenceAutocollant],
         etatDuSupportDeVisibiliteBonMauvais: map[dbetatDuSupportDeVisibiliteBonMauvais],
         numeroCagnt: map[dbnumeroCagnt],
         commercial: map[dbcommercial],
        dotee: map[dbRegContent]
     );
   }


}
