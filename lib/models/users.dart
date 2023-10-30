
import 'package:phil_mobile/provider/db_constant.dart';

class Comms {
  String? nomCommerciaux;
  String? nicknameCommerciaux;
  int? id;
  String? mail;
  DateTime? startDateTime;
  DateTime? endDateTime;
  DateTime? startDateTimeR;
  DateTime? endDateTimeR;
  String? password;
  bool? StatusCompte;
  bool checked;

  Comms({
    this.nomCommerciaux,
    this.id,
    this.startDateTime,
    this.endDateTime,
    this.startDateTimeR,
    this.endDateTimeR,
    this.mail,
    this.password,
    this.nicknameCommerciaux,
    this.StatusCompte,
    this.checked = true
  });


  factory Comms.MapCommercial(Map<String, dynamic> map) {
    return Comms(
        nomCommerciaux: map[dbName],
        id: map[dbId],
        password: map[dbPass],
        mail: map[dbMail],
        nicknameCommerciaux: map[dbNickName],
        StatusCompte: map[dbStatusCompteComm],
      startDateTime: DateTime.now().subtract(Duration(days: 7)),
      endDateTime: DateTime.now(),
      startDateTimeR: DateTime.now().subtract(Duration(days: 7)),
      endDateTimeR: DateTime.now(),
    );
  }



}