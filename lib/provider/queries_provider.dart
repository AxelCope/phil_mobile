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
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = false
  }) async {
    GDirectRequest.select(
        sql:
        " WITH doted AS ( "
        "SELECT * "
            "FROM univers "
            "), "
            "dotation AS ( "
            "SELECT COUNT(tomsisdn) AS dotreg, tomsisdn "
            "FROM give "
            "WHERE EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "AND TOMSISDN IN (SELECT NUMERO_FLOOZ FROM univers ) "
            "GROUP BY tomsisdn "
            ") "
            "SELECT doted.*, COALESCE(dotation.dotreg, 0) AS dotreg "
            "FROM doted "
            "LEFT JOIN dotation ON doted.numero_flooz = dotation.tomsisdn "
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
    "from transactions "
            "where (frmsisdn = $pdv or tomsisdn = $pdv) AND "
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
            "numero_commercial = $id ;"

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
            "FROM transactions "
            "WHERE EXTRACT(MONTH FROM TIMESTAMP) = $date AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) AND "
            "(TOMSISDN IN (SELECT NUMERO_FLOOZ FROM univers WHERE NUMERO_CAGNT = $cmId) OR FRMSISDN IN (SELECT NUMERO_FLOOZ FROM univers WHERE NUMERO_CAGNT = $cmId));  "


    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

  Future<void> giveCOmDistinct({
    required date,
    required commId,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        " select sum(givecom) as somme, frname as pdvs, frmsisdn as numero "
            "from ( "
            "select sum(amount) as givecom, frname, frmsisdn "
            "from give "
            "where (toprofile = 'BNKAGNT') "
            "AND (frmsisdn in (select numero_flooz from univers where numero_cagnt = $commId)) "
            "AND EXTRACT(MONTH FROM TIMESTAMP) = $date AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "group by frmsisdn, frname "
            "union all "
            "select sum(amount) as  to_client_amount,toname, tomsisdn "
            "from give "
            "where (frprofile = 'BNKAGNT') "
            "AND (tomsisdn in (select numero_flooz from univers where numero_cagnt = $commId)) "
            "AND EXTRACT(MONTH FROM TIMESTAMP) = $date AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "group by tomsisdn, toname "
            ") tbl "
            "group by frname, frmsisdn; "

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
        sql: "SELECT SUM(fr_amount) sommedotes, frmsisdn pos_msidsn, frname nom_commercial "
            "FROM "
            "( "
            "SELECT SUM(amount) AS fr_amount, frmsisdn, frname "
            "FROM transactions "
            "WHERE TYPE = 'CSIN' AND frmsisdn IN (SELECT numero_flooz FROM univers WHERE numero_cagnt = $cmId) AND EXTRACT(MONTH FROM TIMESTAMP) = $date AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "GROUP BY frmsisdn, frname "
            "UNION ALL "
            "SELECT SUM(amount) AS to_amount, tomsisdn, toname "
            "FROM transactions  "
            "WHERE TYPE = 'AGNT' AND tomsisdn IN (SELECT numero_flooz FROM univers WHERE numero_cagnt = $cmId) AND EXTRACT(MONTH FROM TIMESTAMP) = $date AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "GROUP BY tomsisdn, toname "
            ") tbl "
            "GROUP BY frmsisdn, frname; "

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
    required startDate,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
      sql:
      "SELECT * "
          "FROM univers "
          "WHERE (NUMERO_FLOOZ NOT IN (SELECT frmsisdn FROM transactions WHERE EXTRACT(MONTH FROM TIMESTAMP) = $startDate AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE)) AND NUMERO_FLOOZ NOT IN (SELECT tomsisdn FROM transactions WHERE EXTRACT(MONTH FROM TIMESTAMP) = $startDate AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE))) "
          "AND numero_cagnt =  $cmId AND status = True; "
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
        "select * from give "
        "where (frmsisdn = $id or tomsisdn = $id) "
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
    required date,
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "select pos_solde as solde "
            "from solde_pdvs "
            "where date(date_execution) = '$date' and pos_msisdn = $id; "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

 Future<void> commission({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "select SUM(dealer_commission) as commission "
            "from transactions "
            "where EXTRACT(MONTH from timestamp) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE); "
    ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

}

 Future<void> givecom_total({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "select SUM(GIVECOM_DEBIT_AMOUNT) as commission "
        "from give "
        "where EXTRACT(MONTH from timestamp) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE); "

   ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }

 Future<void> pdvs_actifs({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "SELECT COUNT(*) AS nombre_de_points "
        "FROM ( "
        "SELECT COUNT(id) "
        "FROM ( "
        "SELECT SUM(amount) AS fr_amount, frmsisdn as id "
        "FROM transactions "
        "WHERE TYPE = 'CSIN' "
        "AND frmsisdn IN (SELECT numero_flooz FROM univers) "
        "AND EXTRACT(MONTH from timestamp) = EXTRACT(MONTH FROM CURRENT_DATE) "
        "AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) "
        "group by frmsisdn "
        "UNION ALL "
        "SELECT SUM(amount) AS to_amount, tomsisdn "
        "FROM transactions "
        "WHERE TYPE = 'AGNT' "
        "AND tomsisdn IN (SELECT numero_flooz FROM univers) "
        "AND EXTRACT(MONTH from timestamp) = EXTRACT(MONTH FROM CURRENT_DATE) "
            "AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) "
    "group by tomsisdn "
    ") AS tbl "
    "GROUP BY id "
    ") AS points_avec_10_transactions; "
   ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }


 Future<void> commerciaux({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    bool secure = true
  }) async {
    GDirectRequest.select(
        sql:
        "select numero_cagnt, commercial "
        "from univers "
        "where numero_cagnt IS NOT NULL "
        "group by numero_cagnt, commercial "
        "order by commercial; "
   ).exec(
        secure: secure,
        onSuccess: (Result result) {
          onSuccess(result.data);
        },
        onError: onError
    );
  }



