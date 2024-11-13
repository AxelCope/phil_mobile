import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/model_transactions.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/queries_provider.dart';

class PageTransactions extends StatefulWidget  {
  const PageTransactions({super.key, required this.comms});

  final Comms comms;
  @override
  State<PageTransactions> createState() => _PageTransactionsState();
}

class _PageTransactionsState extends State<PageTransactions> {
  late final QueriesProvider _provider;
  final ScrollController _scrollController = ScrollController();
  bool gotData = true;
  bool getDataError = false;
  List<Transactions> listTransaction = [];



  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    _provider = await QueriesProvider.instance;
    _fetchTransactions();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: ()
          {
            previousPage(context);
          },
        ),
        actions: [
      Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        decoration: BoxDecoration(
          color: Colors.white, // Set the desired background color
          borderRadius: BorderRadius.circular(8.0), // Ajoutez une bordure arrondie si vous le souhaitez
        ),
      richMessage: TextSpan(
      text: 'Légende: \n',
        style: const TextStyle(color: Colors.black),
        children: <InlineSpan>[
          WidgetSpan(child: Icon(Icons.circle, color: philMainColor,)),
          const TextSpan(
            text: 'Représente les dotations que vous effectuez\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const WidgetSpan(child: Icon(Icons.circle, color: Colors.red,)),
          const TextSpan(
            text: 'Représente les dotations du Master\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const WidgetSpan(child: Icon(Icons.circle, color: Colors.grey,)),
          const TextSpan(
            text: 'Réprésente les reconversions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
        waitDuration: const Duration(seconds: 10),
      child: const Icon(Icons.info_outline),

      ),
          IconButton(
            onPressed: () {
              datePicker();
            },
            icon: const Icon(Icons.calendar_month_sharp),
          ),
        ],
        centerTitle: true,
        title: const Text("Mes transactions"),
      ),
      body: allTransactions(),
    );
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      gotData = true;
      getDataError = false;
    });
    _provider.transaction(
        Sdate: widget.comms.startDateTimeT.toString(),
        Edate: widget.comms.endDateTimeT.toString(),
        id: widget.comms.id,
        secure: false,
        onSuccess: (r) {
          setState(() {
            for(var element in r)
            {
              listTransaction.add(Transactions.MapTransact(element));
            }
          });
          setState(() {
            gotData = false;
            getDataError = false;
          });
        },
        onError: (e) {
          setState(() {
            print(e);
            gotData = false;
            getDataError = true;
          });
        });
  }

  Widget allTransactions()
  {
    if(gotData)
    {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 200.0),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(color: Colors.green,),
          ),
        ),
      );
    }
    if(getDataError){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Nous n'avons pas pu contacter le serveur"),
          TextButton(
            child: const Text("Veuillez réessayer", style: TextStyle(color: Colors.green),), onPressed: () {
            setState(() {
              _fetchTransactions();
            });
          },),
        ],
      );
    }
    if(listTransaction.isEmpty)
      {
        return const Center(
          child: SizedBox(
            child: Text("Aucune transaction à cette date"),
          ),
        );
      }
    return Scrollbar(
      trackVisibility: true,
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: listTransaction.length,
          itemBuilder: (context, index)
              {
                return transaction(listTransaction[index]);
              }
      ),
    );
  }
  Widget transaction(Transactions tr)
  {

    Color bandColor = Colors.blue;
    if(int.parse(tr.frmsisdn!) == widget.comms.id)
      {
       bandColor = philMainColor;
      }
    else if(int.parse(tr.frmsisdn!) == 22897391919)
      {
        bandColor = Colors.red;
      }
    else if(int.parse(tr.frmsisdn!) != 22897391919 && int.parse(tr.frmsisdn!) != widget.comms.id)
      {
        bandColor = Colors.grey;
      }

    return
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.5), // Ombre plus subtile
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Coins arrondis pour le ClipPath
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50], // Dégradé de fond
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                left: BorderSide(color: bandColor, width: 5), // Bande colorée
              ),
            ),
            padding: const EdgeInsets.all(10.0), // Ajoutez du padding interne
            child: ListTile(
              title: Text(
                "Montant: ${NumberFormat("#,###,### CFA").format(tr.amount)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Texte en gras pour le titre
                  color: Colors.black87,
                  fontSize: 16.0, // Taille de police pour le titre
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0), // Espacement entre le titre et le sous-titre
                child: Text(
                  "De ${tr.fr_pos_name.toString() == widget.comms.nicknameCommerciaux ? "MOI" : tr.fr_pos_name} à ${ tr.to_pos_name.toString() == widget.comms.nicknameCommerciaux ? "MOI" : tr.to_pos_name}\n\nDate: ${myDate(tr.timestamp)}"
                      "\nRéférence (ID): ${tr.id}",
                  style: const TextStyle(
                    color: Colors.black54, // Couleur de texte plus douce pour le sous-titre
                    fontSize: 14.0, // Taille de police pour le sous-titre
                  ),
                ),
              ),
            ),
          ),
        ),
      );


  }

  datePicker() async{
    List<DateTime> dates = [widget.comms.startDateTimeT!,  ];
    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,

      ),
      dialogSize: const Size(325, 400),
      value: dates,
      borderRadius: BorderRadius.circular(15),
    );
    setState(() {
      if(results!.length == 2)
      {
        widget.comms.startDateTimeT = results[0]!;
        widget.comms.endDateTimeT = results[1]!;
      }else{
        widget.comms.startDateTimeT = results[0]!;
        widget.comms.endDateTimeT = results[0]!;
      }
    });
    _fetchTransactions();
    listTransaction.clear();

  }


  String myDate(formattedString) {
    var day = DateTime
        .parse(formattedString)
        .day;
    var month = DateTime
        .parse(formattedString)
        .month;
    var year = DateTime
        .parse(formattedString)
        .year;
    var hour = DateTime
        .parse(formattedString)
        .hour;
    var minute = DateTime
        .parse(formattedString)
        .minute;

    return "$day-$month-$year $hour:$minute";
  }

}
