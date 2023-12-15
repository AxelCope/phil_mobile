import 'package:phil_mobile/provider/db_constant.dart';
class Dotations {
  int? dotations;
  String? dates;

  Dotations({
      this.dates,
      this.dotations,
  });

  factory Dotations.MapDotations(Map<String, dynamic> map) {
    return Dotations(
      dotations: map[dbRegContent],
      dates: map[dbDates],
    );
  }

}