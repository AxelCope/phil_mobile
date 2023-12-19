import 'package:flutter/cupertino.dart';
import 'package:genos_dart/genos_dart.dart';
import 'package:phil_mobile/models/model_dotations.dart';


class DotationProvider {
  static final DotationProvider _instance = DotationProvider._();
  static bool _initialized = false;

  DotationProvider._();

  static Future<DotationProvider> get instance async {
    if(!_initialized) {
      _initialized  = true;
    }
    return _instance;
  }

  Future<void> getAllDotation({
    required int? commId,
    required String? endDate,
    required String? startDate,
    required ValueChanged<List<Dotations>> onSuccess,
    required ValueChanged<RequestError> onError,
    bool secure = true,
  }) async {
    print('dotation provider ${DateTime.now()}');
    await GDirectRequest.select(

        sql: "SELECT COUNT(DISTINCT TO_POS_NAME) AS dotreg, DATE(TIMESTAMP) AS jours "
            "FROM pso "
        "WHERE DATE(TIMESTAMP) >= '$startDate' AND DATE(TIMESTAMP) <= '$endDate' AND FRMSISDN = $commId "
        "AND TOMSISDN IN (SELECT NUMERO_FLOOZ FROM univers) "
        "GROUP BY jours;",
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          List<Dotations> l = [];
          for (var element in result.data) {
              l.add(Dotations.MapDotations(element));

          }
          onSuccess(l);
        },
        onError: onError
    );
  }
}