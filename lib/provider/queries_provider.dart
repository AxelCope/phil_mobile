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
        " WITH doted AS ( "
        "SELECT * "
            "FROM univers "
            "WHERE numero_cagnt = $id "
            "), "
            "dotation AS ( "
            "SELECT COUNT(tomsisdn) AS dotreg, tomsisdn "
            "FROM give "
            "WHERE EXTRACT(MONTH FROM TIMESTAMP) = $month "
            "AND EXTRACT(YEAR FROM TIMESTAMP) = EXTRACT(YEAR FROM CURRENT_DATE) "
            "AND FRMSISDN = $id "
            "AND TOMSISDN IN (SELECT NUMERO_FLOOZ FROM univers where numero_cagnt = $id) "
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
        "select pos_solde_principal as solde "
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

  Future<void> mois_precedents({
    required Function(List<Map<String, dynamic>>) onSuccess,
    required Function(RequestError) onError,
    required int pdv,
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



}
