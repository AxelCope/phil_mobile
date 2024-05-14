import 'package:phil_mobile/provider/db_constant.dart';


class Versioning {
  String? version;


  Versioning({
    this.version
  });

  factory Versioning.MapVersion(Map<String, dynamic> map) {
    return Versioning(
      version: map[dbVersion],
    );
  }
}
