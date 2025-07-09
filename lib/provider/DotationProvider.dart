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
    required String? commId,
    required String? endDate,
    required String? startDate,
    required ValueChanged<List<Dotations>> onSuccess,
    required ValueChanged<RequestError> onError,
    bool secure = true,
  }) async {
    await GDirectRequest.select(

          sql:
          "SELECT COUNT(DISTINCT tomsisdn) AS dotreg, DATE(timestamp) AS jours "
    "FROM transactions_pdvs "
    "WHERE DATE(timestamp) >= '$startDate' AND DATE(timestamp) <= '$endDate' AND frmsisdn = '$commId' "
    "AND tomsisdn IN (SELECT numero_flooz FROM univers) "
    "GROUP BY jours; "
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