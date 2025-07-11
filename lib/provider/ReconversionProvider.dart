import 'package:flutter/cupertino.dart';
import 'package:genos_dart/genos_dart.dart';
import 'package:phil_mobile/models/model_reconversion.dart';


class ReconversionProvider {
  static final ReconversionProvider _instance = ReconversionProvider._();
  static bool _initialized = false;

  ReconversionProvider._();

  static Future<ReconversionProvider> get instance async {
    if(!_initialized) {
      _initialized  = true;
    }
    return _instance;
  }

  Future<void> getAllReconversion({
    required String? commId,
    required String? endDate,
    required String? startDate,
    required ValueChanged<List<Rec>> onSuccess,
    required ValueChanged<RequestError> onError,

    bool secure = true,
  }) async {
    await GDirectRequest.select(
          sql:
          "SELECT SUM(amount) AS reconversion, DATE(timestamp) AS jours "
      "FROM transactions_pdvs "
      "WHERE "
      "DATE(timestamp) >= '$startDate' AND DATE(timestamp) <= '$endDate' "
      "AND (frmsisdn IN (SELECT numero_flooz FROM univers WHERE numero_cagnt = '$commId') AND tomsisdn = '$commId') "
      "GROUP BY jours; "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          List<Rec> l = [];
          for (var element in result.data) {
            if(element['reconversion'] != null) {
              l.add(Rec.MapComm(element));
            }
          }
          onSuccess(l);
        },
        onError: onError
    );
  }
}