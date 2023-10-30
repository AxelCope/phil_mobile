import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/Dotations.dart';
import 'package:phil_mobile/models/Rec.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/provider/DotationProvider.dart';
import 'package:phil_mobile/provider/ReconversionProvider.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Performances extends StatefulWidget {
  const Performances({
    Key? key,
    required this.comms
  }) : super(key: key);

  final Comms comms;

  @override
  State<Performances> createState() => _PerformancesState();
}

class _PerformancesState extends State<Performances> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  previousPage(context);
                }
            ),
            title: Text('Performances'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Dotations'),
                Tab(text: 'Reconversions'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DetailsDotations(comms: widget.comms),
              DetailsReconversion(comms: widget.comms),
            ],
          ),
        ),
    );
  }
}

class DetailsDotations extends StatefulWidget {
  const DetailsDotations({
    Key? key,
    required this.comms
  }) : super(key: key);

  final Comms comms;


  @override
  State<DetailsDotations> createState() => _DetailsDotationsState();
}

class _DetailsDotationsState extends State<DetailsDotations> with AutomaticKeepAliveClientMixin{


  List<Dotations> ListDotations = [];
  List<String> labels = ["Courbes de dotations", "Courbe de reconversions"];
  bool gotData = true;
  bool getDataError = false;
  late final QueriesProvider _provider;
  late DotationProvider dv;

  DateTime dt = DateTime.now().subtract(const Duration(days: 7));


  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    dv = await DotationProvider.instance;
    _provider = await QueriesProvider.instance;
    _fetchData();
    //widget.comms.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: buildWidget()
    );
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

    return "$day-$month-$year";
  }


  List<ChartSeries<dynamic, dynamic>> gotCHarts()
  {
    return <ChartSeries>[
      LineSeries<Dotations, String>(
        dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            color: Colors.black
        ),
        name: 'Dotations journalières',
        dataSource: ListDotations,
        xValueMapper: (Dotations rt, _) => myDate(rt.dates),
        yValueMapper: (Dotations rt, _) => rt.dotations,
        markerSettings: MarkerSettings(isVisible: true)
      ),
    ];
  }

  Widget Chart()
  {
    if(gotData)
    {
      return const Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 200.0),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if(getDataError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 200.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Réessayez.', style: TextStyle(fontSize: 25),),
            ),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Nous n\'avons pas pu charger la page. Réessayez ultérieurement.', style: TextStyle(fontSize: 15),),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  style: ButtonStyle(backgroundColor:MaterialStateProperty.all(Colors.blue)),
                  child: const Text("Actualiser la page", style: TextStyle(color: Colors.black)), onPressed: (){_fetchData();}),
            )

          ],
        ),
      );
    }

    return Container(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              SfCartesianChart(
              title: ChartTitle(
                //text: "Dotation journalière de ${widget.comms.nomCommerciaux}",
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              legend: Legend(
                isVisible: false,
                toggleSeriesVisibility: true,
                textStyle: const TextStyle(
                  fontSize: 12,
                ),
              ),
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                minorGridLines: MinorGridLines(width: 0),
                axisBorderType: AxisBorderType.withoutTopAndBottom,
                labelStyle: const TextStyle(
                  fontSize: 10, // Augmenter la taille de la police des labels
                  fontWeight: FontWeight.bold, // Rendre la police en gras si nécessaire
                ),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(
                  fontSize: 12,
                ),
              ),
              series: gotCHarts(),
            ),
          ],
        ),
      ),
    );
  }

  Widget averageDotationCard()
  {
    var somme = 0.0 ;
    var average = 0;
    for(var i = 0; i < ListDotations.length; i++)
    {
      somme += ListDotations[i].dotations!;
    }
    average = (somme == 0 ? 0 : somme / ListDotations.length).toInt();

    return  Card(
      elevation: 5, // Ajoute une ombre à la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Coins arrondis
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Espacement intérieur
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Moyenne de Dotations de ${widget.comms.nomCommerciaux}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), // Police plus grande et en gras
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${average}/jours",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green), // Police plus grande, en gras et en couleur
                ),
                Icon(
                  Icons.star,
                  color: Colors.orange, // Couleur de l'icône étoile
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  Widget maxDotation()
  {
    int max = 0;
    if(ListDotations.isNotEmpty)
    {
      var max = ListDotations[0].dotations;
    }
    else {
      max = 0;
    }
    for(var i = 0; i < ListDotations.length; i++)
    {
      if( ListDotations[i].dotations! > max)
      {
        max = ListDotations[i].dotations!;
      }
      else{
        max = max;
      }
    }

    return  Card(
      elevation: 5, // Ajoute une ombre à la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Coins arrondis
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Espacement intérieur
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Plus haute Dotation de ${widget.comms.nomCommerciaux}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), // Police plus grande et en gras
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${max}",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green), // Police plus grande, en gras et en couleur
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.green, // Couleur de l'icône flèche vers le haut
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  Widget headerCard()
  {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        children: [
          averageDotationCard(),
          SizedBox(width: 20,),
          maxDotation(),
        ],
      ),
    );
  }

  Widget buildWidget()
  {
    return ListView(
      //shrinkWrap: true,
      children: [
        headerCard(),
        Chart(),
        ElevatedButton(
          onPressed: () {
            datePicker();
          },
          child: Text('Selectionner la plage de dates'),
        ),
      ],
    );
  }

  // Widget averageDotationCard()
  // {
  //   var somme = 0 ;
  //   var average = 0 ;
  //   for(var i = 0; i < ListDotations.length; i++)
  //   {
  //     somme += ListDotations[i].dotations!;
  //   }
  //   average = (somme == 0 ? 0 : somme / ListDotations.length).toInt();
  //
  //   return  Container(
  //     width: 400,
  //     child: Card(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Moyenne de Dotation de ${widget.comms.nomCommerciaux}", style: TextStyle(fontSize: 20),),
  //           SizedBox(height: 30,),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text("${average}/jours", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  //               Image.asset("assets/page_details_commerciaux/chart svg.svg")
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget maxDotation()
  // {
  //   int max = 0;
  //   if(ListDotations.isNotEmpty)
  //   {
  //     var max = ListDotations[0].dotations;
  //   }
  //   else {
  //     max = 0;
  //   }
  //   for(var i = 0; i < ListDotations.length; i++)
  //   {
  //     if( ListDotations[i].dotations! > max)
  //     {
  //       max = ListDotations[i].dotations!;
  //     }
  //     else{
  //       max = max;
  //     }
  //   }
  //
  //   return  Container(
  //     width: 400,
  //     child: Card(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Plus haute dotation ${widget.comms.nomCommerciaux}", style: TextStyle(fontSize: 20),),
  //           SizedBox(height: 30,),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text("${max}", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  //               SvgPicture.asset("assets/page_details_commerciaux/chart1 svg.svg")
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget headerCard()
  // {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
  //     child: Wrap(
  //       children: [
  //         averageDotationCard(),
  //         SizedBox(width: 20,),
  //         maxDotation(),
  //       ],
  //     ),
  //   );
  // }

   datePicker() async{
    List<DateTime> _dates = [DateTime.now(),  ];
       var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,

      ),
      dialogSize: const Size(325, 400),
      value: _dates,
      borderRadius: BorderRadius.circular(15),
    );
       setState(() {
             if(results!.length == 2)
               {
                 widget.comms.startDateTime = results[0]!;
                 widget.comms.endDateTime = results[1]!;
               }else{
               widget.comms.startDateTime = results[0]!;
               widget.comms.endDateTime = results[0]!;
             }
       });
       _fetchData();

  }


  Future<void> _fetchData() async {
    setState(() {
      gotData = true;
      getDataError = false;
    });
    dv.getAllDotation(
        startDate: widget.comms.startDateTime.toString(),
        endDate: widget.comms.endDateTime.toString(),
        commId: widget.comms.id,
        secure: false,
        onSuccess: (r) {
          setState(() {
            ListDotations = r;
          });
          setState(() {
            gotData = false;
            getDataError = false;
          });
        },
        onError: (e) {
          setState(() {
            gotData = false;
            getDataError = true;
          });
          print(e);
        });
  }


  @override
  bool get wantKeepAlive => true;

}


class DetailsReconversion extends StatefulWidget {
  const DetailsReconversion({Key? key,
    required this.comms}) : super(key: key);
  final Comms comms;
  @override
  State<DetailsReconversion> createState() => _DetailsReconversionState();
}

class _DetailsReconversionState extends State<DetailsReconversion> with AutomaticKeepAliveClientMixin{

  List<Rec> reconversion = [];
  late ReconversionProvider rv;
  bool gotData = true;
  bool getDataError = false;
  DateTime dt = DateTime.now().subtract(const Duration(days: 7));


  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    rv = await ReconversionProvider.instance;
    _fetchDataRec();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
          body: Container(
              child: buildWidget())
      );
  }
  Future<void> _fetchDataRec() async {
    setState(() {
      gotData = true;
      getDataError = false;
    });
    rv.getAllReconversion(
        startDate: widget.comms.startDateTimeR.toString(),
        endDate: widget.comms.endDateTimeR.toString(),
        commId: widget.comms.id,
        secure: false,
        onSuccess: (r) {
          setState(() {
            gotData = false;
            getDataError = false;
          });
          setState(() {
            reconversion = r;
          });
        },
        onError: (e) {
          setState(() {
            gotData = false;
            getDataError = true;
          });
          print(e);
        });
  }

  Widget chart()
  {
    if(gotData)
    {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 200.0),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if(getDataError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 200.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:  [
            const Padding(
              padding:   EdgeInsets.all(8.0),
              child: Text('Réessayez.', style: TextStyle(fontSize: 25),),
            ),

            const Padding(
              padding:   EdgeInsets.all(8.0),
              child: Text('Nous n\'avons pas pu charger la page. Réessayez ultérieurement.', style: TextStyle(fontSize: 15),),
            ),

            Padding(
              padding:   const EdgeInsets.all(8.0),
              child: TextButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                  child: const Text("Actualiser la page", style: TextStyle(color: Colors.black)), onPressed: (){_fetchDataRec();}),
            )

          ],
        ),
      );
    }

    return Container(
      child: Card(
        child: Column(
          children: [
            //DatePickers(),
            SfCartesianChart(
              title: ChartTitle(
                text: "Reconversion journalière de ${widget.comms.nomCommerciaux}",
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              legend: Legend(
                isVisible: false,
                toggleSeriesVisibility: true,
                textStyle: const TextStyle(
                  fontSize: 12,
                ),
              ),
              primaryXAxis: CategoryAxis(

                majorGridLines: MajorGridLines(width: 0),
                minorGridLines: MinorGridLines(width: 0),
                axisBorderType: AxisBorderType.withoutTopAndBottom,
                labelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat("#,###,### CFA"),
                labelStyle: const TextStyle(
                  fontSize: 12,
                ),
              ),
              series: gotCHarts(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWidget()
  {
    return ListView(
      shrinkWrap: true,
      children: [
        headerCard(),
        chart(),
        ElevatedButton(
          onPressed: () {
            datePicker();
          },
          child: Text('Selectionner la plage de daes'),
        ),
      ],
    );
  }

  datePicker() async{
    List<DateTime> _dates = [DateTime.now(),  ];
    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,

      ),
      dialogSize: const Size(325, 400),
      value: _dates,
      borderRadius: BorderRadius.circular(15),
    );
    setState(() {
      if(results!.length == 2)
      {
        widget.comms.startDateTimeR = results[0]!;
        widget.comms.endDateTimeR = results[1]!;
      }else{
        widget.comms.startDateTimeR = results[0]!;
        widget.comms.endDateTimeR = results[0]!;
      }
    });
    _fetchDataRec();

  }


  List<ChartSeries<dynamic, dynamic>> gotCHarts()
  {
    return <ChartSeries>[
      ColumnSeries<Rec, String>(
        dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            color: Colors.black
        ),
        markerSettings: const MarkerSettings(isVisible: false),
        name: 'Reconversion',
        dataSource: reconversion,
        xValueMapper: (Rec rc, _) => myDate(rc.date),
        yValueMapper: (Rec rc, _) => rc.reconversion,
      ),
    ];
  }

  Widget averageDotationCard()
  {
    var somme = 0.0 ;
    var average = 0;
    for(var i = 0; i < reconversion.length; i++)
    {
      somme += reconversion[i].reconversion!;
    }
    average = (somme == 0 ? 0 : somme / reconversion.length).toInt();

    return  Card(
      elevation: 5, // Ajoute une ombre à la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Coins arrondis
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Espacement intérieur
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Moyenne de Reconversion de ${widget.comms.nomCommerciaux}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), // Police plus grande et en gras
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${NumberFormat("#,###,### CFA").format(average)}/jours",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green), // Police plus grande, en gras et en couleur
                ),
                Icon(
                  Icons.star,
                  color: Colors.orange, // Couleur de l'icône étoile
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  Widget maxDotation()
  {
    double max = 0.0;
    if(reconversion.isNotEmpty)
    {
      var max = reconversion[0].reconversion;
    }
    else {
      max = 0;
    }
    for(var i = 0; i < reconversion.length; i++)
    {
      if( reconversion[i].reconversion! > max)
      {
        max = reconversion[i].reconversion!;
      }
      else{
        max = max;
      }
    }

    return  Card(
      elevation: 5, // Ajoute une ombre à la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Coins arrondis
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Espacement intérieur
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Plus haute Reconversion de ${widget.comms.nomCommerciaux}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), // Police plus grande et en gras
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${NumberFormat("#,###,### CFA").format(max)}",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green), // Police plus grande, en gras et en couleur
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.green, // Couleur de l'icône flèche vers le haut
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  Widget headerCard()
  {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        children: [
          averageDotationCard(),
          SizedBox(width: 20,),
          maxDotation(),
        ],
      ),
    );
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

    return "$day-$month-$year";
  }

  @override
  bool get wantKeepAlive => true;
}