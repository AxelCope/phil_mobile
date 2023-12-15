
import 'package:phil_mobile/provider/db_constant.dart';

class Rec {
  double? reconversion;
  String? date;
  Rec({
    this.reconversion,
    this.date,
  });

  factory Rec.MapComm(Map<String, dynamic> map) {
    return Rec(
      reconversion: double.parse(map[dbRec]),
      date: map[dbDates],
    );
  }
}