import 'package:genos_dart/genos_dart.dart';

class QueriesProvider {
  static final QueriesProvider _instance = QueriesProvider._();
  static bool _initialized = false;

  QueriesProvider._();

  static Future<QueriesProvider> get instance async {
    if (!_initialized) {
      _initialized = true;
    }
    return _instance;
  }

  Future<void> fetchUsers({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = false
  }) async {
    GDirectRequest.select(
        sql:
        " select * from commercial; "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

  Future<void> fetchPdvs({
    required id,
    required month,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = false
  }) async {
    GDirectRequest.select(
        sql:
        "WITH doted AS ("
            "SELECT * "
            "FROM univers "
            "WHERE numero_cagnt = '$id' "
            "), "
            "dotation AS ("
            "SELECT "
            "COUNT(tomsisdn) AS dotreg, "
            "tomsisdn "
            "FROM transactions_pdvs "
            "WHERE EXTRACT(MONTH FROM timestamp) = EXTRACT(MONTH FROM CURRENT_DATE) "
            "AND EXTRACT(YEAR FROM timestamp) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "AND frmsisdn = '$id' "
            "AND transaction_type = 'GIVE' "
            "AND tomsisdn IN (SELECT numero_flooz FROM univers WHERE numero_cagnt = '$id') "
            "GROUP BY tomsisdn "
            "), "
            "soldes AS ("
            "SELECT "
            "pos_msisdn, "
            "date_execution, "
            "pos_solde_principal AS solde "
            "FROM balance_pdv "
            "WHERE DATE(date_execution) = CURRENT_DATE "
            ") "
            "SELECT "
            "doted.*, "
            "COALESCE(dotation.dotreg, 0) AS dotreg, "
            "COALESCE(soldes.solde, 0) AS pos_solde_principal "
            "FROM doted "
            "LEFT JOIN dotation "
            "ON doted.numero_flooz = dotation.tomsisdn "
            "LEFT JOIN soldes "
            "ON doted.numero_flooz = soldes.pos_msisdn "
            "ORDER BY solde ASC; "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }


  Future<void> getCA({
    required pdv,
    required month,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = false
  }) async {
    GDirectRequest.select(
        sql:
        "select COALESCE(SUM(pos_commission), 0) as somme "
    "from transactions_pdvs "
            "where (frmsisdn = '$pdv' or tomsisdn = '$pdv') AND "
             " (EXTRACT(MONTH FROM TIMESTAMP) = $month "
    "AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE)); "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

  Future<void> objectifsbyComm({
    required date,
    required id,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "SELECT objectifs/2 as somme "
            "FROM objectifs_moov "
            "WHERE mois = '$date' and "
            "numero_commercial = '$id' ;"

    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

  Future<void> commissionCommerciaux({
    required date ,
    required cmId ,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "SELECT SUM(DEALER_COMMISSION) as somme "
            "FROM transactions_pdvs "
            "WHERE EXTRACT(MONTH FROM TIMESTAMP) = $date AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) AND "
            "(TOMSISDN IN (SELECT NUMERO_FLOOZ FROM univers WHERE NUMERO_CAGNT = '$cmId') OR FRMSISDN IN (SELECT NUMERO_FLOOZ FROM univers WHERE NUMERO_CAGNT = '$cmId'));  "


    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

  Future<void> giveComDistinct({
    required date,
    required commId,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "SELECT "
            "u.nom_du_point AS pdvs, "
            "u.numero_flooz AS numero, "
            "SUM(t.givecom_debit_amount) * 1000 AS somme "
            "FROM univers u "
            "LEFT JOIN transactions_pdvs t "
            "ON t.tomsisdn = u.numero_flooz "
            "WHERE u.numero_cagnt = '$commId' "
            "AND EXTRACT(MONTH FROM t.timestamp) = EXTRACT(MONTH FROM CURRENT_DATE) "
            "AND EXTRACT(YEAR FROM t.timestamp) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "AND t.transaction_type = 'GIVE' "
            "GROUP BY u.numero_flooz, u.nom_du_point "
            "HAVING SUM(t.givecom_debit_amount) > 0 "
            "ORDER BY somme DESC;"


    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }


  Future<void> SegmentationParComm({
    required cmId,
    required date,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:

        "WITH transactions_pdvs AS ( "
            "SELECT "
            "CASE "
            "WHEN transaction_type = 'CashIn' THEN frmsisdn "
            "WHEN transaction_type = 'CashOut' THEN tomsisdn "
            "END AS pdv_number, "
            "CASE "
            "WHEN transaction_type = 'CashIn' THEN (SELECT nom_du_point FROM univers WHERE numero_flooz = frmsisdn) "
            "WHEN transaction_type = 'CashOut' THEN (SELECT nom_du_point FROM univers WHERE numero_flooz = tomsisdn) "
            "END AS pdv_name, "
            "SUM(amount) AS sommedotes "
            "FROM transactions_pdvs "
            "WHERE (transaction_type = 'CashIn' OR transaction_type = 'CashOut') "
            "AND EXTRACT(MONTH FROM timestamp) = EXTRACT(MONTH FROM CURRENT_DATE) "
            "AND EXTRACT(YEAR FROM timestamp) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "GROUP BY "
            "CASE "
            "WHEN transaction_type = 'CashIn' THEN frmsisdn "
            "WHEN transaction_type = 'CashOut' THEN tomsisdn "
            "END, "
            "CASE "
            "WHEN transaction_type = 'CashIn' THEN (SELECT nom_du_point FROM univers WHERE numero_flooz = frmsisdn) "
            "WHEN transaction_type = 'CashOut' THEN (SELECT nom_du_point FROM univers WHERE numero_flooz = tomsisdn) "
            "END "
            ") "
            "SELECT "
            "COALESCE(t.pdv_name, u.nom_du_point) AS nom_commercial, "
            "COALESCE((SELECT nom_du_point FROM univers WHERE numero_flooz = t.pdv_number), u.nom_du_point) AS pos_msidsn, "
            "COALESCE(t.sommedotes, 0) AS sommedotes "
            "FROM univers u "
            "LEFT JOIN transactions_pdvs t "
            "ON t.pdv_number = u.numero_flooz "
            "WHERE u.numero_cagnt = '$cmId' "
            "ORDER BY sommedotes DESC, nom_commercial;"

    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

  Future<void> fetchInactifsZone({
    required cmId,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
      sql:
      "SELECT "
      "u.* "
      "FROM univers u "
      "WHERE u.numero_flooz NOT IN ( "
      "SELECT t.frmsisdn "
      "FROM transactions_pdvs t "
      "WHERE t.timestamp >= date_trunc('month', CURRENT_DATE) "
      "AND t.timestamp < (CURRENT_DATE - interval '1 day') + interval '1 day' "
      "UNION "
      "SELECT t.tomsisdn "
      "FROM transactions_pdvs t "
      "WHERE t.timestamp >= date_trunc('month', CURRENT_DATE) "
      "AND t.timestamp < (CURRENT_DATE - interval '1 day') + interval '1 day' "
      ") "
      "AND numero_cagnt = '$cmId' "
      "ORDER BY u.commercial, u.nom_du_point; "
      ,
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }


  Future<void> changerMdpUsers({
    required username,
    required newPassword,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
            "update commercial "
            "set password = '$newPassword' "
            "where pos_msidsn = '$username' "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }


 Future<void> transaction({
    required id,
    required Sdate,
    required Edate,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "SELECT "
            "referenceid, "
            "transaction_type AS type, "
            "frmsisdn, "
            "tomsisdn, "
            "status, "
            "COALESCE(amount, 0) AS amount, "
            "timestamp, "
            "COALESCE(pos_balance_before, 0) AS bef, "
            "COALESCE(pos_balance_after, 0) AS aft, "
            "frname_dealer AS give_frname, "
            "toname_dealer AS give_toname, "
            "frprofile, "
            "toprofile, "
            "COALESCE(dealer_commission, 0) AS dcom, "
            "COALESCE(pos_commission, 0) AS poscom "
            "FROM transactions_pdvs "
            "WHERE (frmsisdn = '$id' OR tomsisdn = '$id') "
            "AND (DATE(timestamp) >= '$Sdate' AND DATE(timestamp) <= '$Edate') "
            "AND transaction_type = 'GIVE' "
            "ORDER BY timestamp; "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

   Future<void> transaction_pdv({
    required id,
    required Sdate,
    required Edate,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "select * from transactions_pdvs "
        "where (frmsisdn = '$id' or tomsisdn = '$id') "
        "and (DATE(timestamp) >= '$Sdate' and DATE(timestamp) <= '$Edate') "
            "ORDER BY timestamp "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }




 Future<void> solde({
    required id,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "SELECT pos_solde_principal AS solde "
        "FROM balance_pdv "
        "WHERE DATE(date_execution) = CURRENT_DATE "
    "AND pos_msisdn = '$id'; "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

  Future<void> version({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "select version "
            "from versioning "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

    Future<void> rankingCommerciaux({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "SELECT "
        "t1.commercial, "
        "SUM(t2.dealer_commission) AS somme "
        "FROM univers t1 "
        "INNER JOIN transactions_pdvs t2 "
        "ON t1.numero_flooz = t2.frmsisdn "
        "OR t1.numero_flooz = t2.tomsisdn "
        "WHERE "
        "DATE_TRUNC('month', t2.timestamp) = DATE_TRUNC('month', CURRENT_DATE) "
        "GROUP BY "
        "t1.commercial "
        "ORDER BY "
        "somme DESC; "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }




  Future<void> mois_precedents({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    required String pdv,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "select sum(pos_commission) as somme, EXTRACT(MONTH FROM timestamp) as mois "
        "from transactions "
         "where (tomsisdn = $pdv or frmsisdn = $pdv ) "
    "AND EXTRACT(YEAR FROM timestamp) = EXTRACT(YEAR FROM CURRENT_DATE) "
    "group by mois; "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

  Future<void> getDealerCA({
    required pdv,
    required month,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = false
  }) async {
    GDirectRequest.select(
        sql:
        "SELECT COALESCE(SUM(dealer_commission), 0) AS somme, "
    "CURRENT_DATE AS date_du_jour "
    "FROM transactions_pdvs "
    "WHERE (frmsisdn = '$pdv' OR tomsisdn = '$pdv') "
    "AND date_trunc('month', timestamp) = date_trunc('month', CURRENT_DATE); "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }


}
