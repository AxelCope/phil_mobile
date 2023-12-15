import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:phil_mobile/models/model_dotations.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/DotationProvider.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    dv = await DotationProvider.instance;
    _provider = await QueriesProvider.instance;
    _fetchData();
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
          markerSettings: const MarkerSettings(isVisible: true)
      ),
    ];
  }

  Widget Chart()
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
                  style: ButtonStyle(backgroundColor:MaterialStateProperty.all(philMainColor)),
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
              legend: const Legend(
                isVisible: false,
                toggleSeriesVisibility: true,
                textStyle: TextStyle(
                  fontSize: 12,
                ),
              ),
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                minorGridLines: const MinorGridLines(width: 0),
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
      elevation: 5,
      child: ClipPath(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: philMainColor, width: 5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10), // Ajoute une marge intérieure pour un espacement équilibré
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Moyenne de Dotations de ${widget.comms.nomCommerciaux}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Police plus grande et en gras
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$average/jours",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), // Police plus grande, en gras et en couleur
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.orange, // Couleur de l'icône étoile
                        ),
                      ],
                    ),
                  ],
                ),],
            ),
          ),
        ),
      ),
    );


    //   Card(
    //   elevation: 5, // Ajoute une ombre à la carte
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(15), // Coins arrondis
    //   ),
    //   child: Padding(
    //     padding: const EdgeInsets.all(10.0), // Espacement intérieur
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           "Moyenne de Dotations de ${widget.comms.nomCommerciaux}",
    //           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), // Police plus grande et en gras
    //         ),
    //         const SizedBox(height: 10),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               "$average/jours",
    //               style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green), // Police plus grande, en gras et en couleur
    //             ),
    //             const Icon(
    //               Icons.star,
    //               color: Colors.orange, // Couleur de l'icône étoile
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );

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

    return
      Card(
        elevation: 5,
        child: ClipPath(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: philMainColor, width: 5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10), // Ajoute une marge intérieure pour un espacement équilibré
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                                  "Plus haute Dotation de ${widget.comms.nomCommerciaux}",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Police plus grande et en gras
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "$max",
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), // Police plus grande, en gras et en couleur
                                    ),
                                    const Icon(
                                      Icons.trending_up,
                                      color: Colors.green, // Couleur de l'icône flèche vers le haut
                                    ),
                        ],
                      ),
                    ],
                  ),],
              ),
            ),
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
          const SizedBox(width: 20,),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: philMainColor
          ),
          onPressed: () {
            datePicker();
          },
          child: const Text('Selectionner la plage de dates', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }


  datePicker() async{
    List<DateTime> dates = [widget.comms.startDateTime!,  ];
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
        widget.comms.startDateTime = results[0]!;
        widget.comms.endDateTime = results[1]!;
      }else{
        widget.comms.startDateTime = results[0]!;
        widget.comms.endDateTime = results[0]!;
      }
    });
    _fetchData();
    ListDotations.clear();

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

