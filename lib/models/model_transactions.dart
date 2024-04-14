
import 'package:phil_mobile/provider/db_constant.dart';

class Transactions{
  String?  type;
  String?  frmsisdn;
  String?  tomsisdn;
  int?  amount;
  String?  timestamp;
  int?  pos_balance_before;
  int?  pos_balance_after;
  String?  fr_pos_name;
  String?  to_pos_name;
  String?  frprofile;
  String?  toprofile;
  int?  dealer_commission;
  int?  pos_commission;

  Transactions({
    this.amount,
    this.dealer_commission,
    this.fr_pos_name,
    this.frmsisdn,
    this.frprofile,
    this.pos_balance_after,
    this.pos_balance_before,
    this.pos_commission,
    this.timestamp,
    this.to_pos_name,
    this.tomsisdn,
    this.toprofile,
    this.type
  });

  factory Transactions.MapTransact(Map<String, dynamic> map)
  {
    return Transactions(
        type: map[dbType],
        frmsisdn: map[dbFrms],
        tomsisdn: map[dbToms],
        amount: map[dbAmount],
        timestamp: map[dbTime],
        pos_balance_before: map[dbBef],
        pos_balance_after: map[dbAmount],
        fr_pos_name: map[dbGiveFrname],
        to_pos_name: map[dbGiveToname],
        frprofile: map[dbFrprofile],
        toprofile: map[dbToprofile],
        dealer_commission: map[dbDcom],
        pos_commission: map[dbPoscom]
    );
  }

}