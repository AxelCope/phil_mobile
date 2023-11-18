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
  int? id;

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
      startDateTime: DateTime.now().subtract(Duration(days: 7)),
      endDateTime: DateTime.now(),
      startDateTimeR: DateTime.now().subtract(Duration(days: 7)),
      endDateTimeR: DateTime.now(),
    );
  }
}
