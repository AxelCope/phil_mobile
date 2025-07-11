// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:phil_mobile/provider/db_constant.dart';
part 'users.g.dart';


@HiveType(typeId: 0)
class Comms {
  @HiveField(0)
  String? nomCommerciaux;

  @HiveField(1)
  String? nicknameCommerciaux;

  @HiveField(2)
  String? id;

  @HiveField(3)
  String? mail;

  @HiveField(4)
  DateTime? startDateTime;

  @HiveField(5)
  DateTime? endDateTime;

  @HiveField(6)
  DateTime? startDateTimeR;

  @HiveField(7)
  DateTime? endDateTimeR;

  @HiveField(8)
  String? password;

  @HiveField(9)
  bool? StatusCompte;

  @HiveField(10)
  bool checked;

  @HiveField(11)
  DateTime? startDateTimeT;

  @HiveField(12)
  DateTime? endDateTimeT;

  Comms({
    this.nomCommerciaux,
    this.id,
    this.startDateTime,
    this.endDateTime,
    this.startDateTimeR,
    this.endDateTimeR,
    this.startDateTimeT,
    this.endDateTimeT,
    this.mail,
    this.password,
    this.nicknameCommerciaux,
    this.StatusCompte,
    this.checked = true,
  });

  factory Comms.MapCommercial(Map<String, dynamic> map) {
    return Comms(
      nomCommerciaux: map[dbName],
      id: map[dbId],
      password: map[dbPass],
      mail: map[dbMail],
      nicknameCommerciaux: map[dbNickName],
      StatusCompte: map[dbStatusCompteComm],
      startDateTime: DateTime.now().subtract(const Duration(days: 7)),
      endDateTime: DateTime.now(),
      startDateTimeR: DateTime.now().subtract(const Duration(days: 7)),
      endDateTimeR: DateTime.now(),
      startDateTimeT: DateTime.now().subtract(const Duration(days: 7)),
      endDateTimeT: DateTime.now(),
    );
  }
}
