import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/models/model_reconversion.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/ReconversionProvider.dart';

class DetailsReconversion extends StatefulWidget {
  const DetailsReconversion({Key? key, required this.comms}) : super(key: key);
  final Comms comms;

  @override
  State<DetailsReconversion> createState() => _DetailsReconversionState();
}

class _DetailsReconversionState extends State<DetailsReconversion> with AutomaticKeepAliveClientMixin {
  List<Rec> reconversion = [];
  late ReconversionProvider rv;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
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
      body: Container(child: buildWidget()),
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
          print(e);
          gotData = false;
          getDataError = true;
        });
      },
    );
  }

  Widget chart() {
    if (gotData) {
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

    if (getDataError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 200.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Réessayez.', style: TextStyle(fontSize: 25)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Nous n\'avons pas pu charger la page. Réessayez ultérieurement.',
                style: TextStyle(fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                child: const Text("Actualiser la page", style: TextStyle(color: Colors.black)),
                onPressed: () {
                  _fetchDataRec();
                },
              ),
            ),
          ],
        ),
      );
    }
    final maxDotation = getMaxDotation();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold, color: philMainColor),
              ),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  reconversion.sort((a, b) {
                    final aDate = DateTime.parse(a.date!);
                    final bDate = DateTime.parse(b.date!);
                    return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
                  });
                });
              },
            ),
            DataColumn(
              label: Text(
                'Reconversion',
                style: TextStyle(fontWeight: FontWeight.bold, color: philMainColor),
              ),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  reconversion.sort((a, b) =>
                  ascending ? a.reconversion!.compareTo(b.reconversion!) : b.reconversion!.compareTo(a.reconversion!));
                });
              },
            ),
          ],
          rows: reconversion.map((dotation) {
            final isMax = dotation.reconversion == maxDotation && maxDotation != 0;
            return DataRow(
              color: isMax
                  ? MaterialStateProperty.all(philMainColor.withOpacity(0.1))
                  : null,
              cells: [
                DataCell(
                  Text(
                    myDate(dotation.date!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isMax ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Text(
                        NumberFormat("#,###,### CFA").format(dotation.reconversion),
                        style: TextStyle(
                          fontSize: 14,
                          color: isMax ? philMainColor : Colors.black,
                          fontWeight: isMax ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isMax)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.trending_up, color: Colors.green, size: 18),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildWidget() {
    return ListView(
      shrinkWrap: true,
      children: [
        headerCard(),
        chart(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: philMainColor),
          onPressed: () {
            datePicker();
          },
          child: const Text('Selectionner la plage de dates', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  datePicker() async {
    List<DateTime> dates = [widget.comms.startDateTimeR!];
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
      if (results!.length == 2) {
        widget.comms.startDateTimeR = results[0]!;
        widget.comms.endDateTimeR = results[1]!;
      } else {
        widget.comms.startDateTimeR = results[0]!;
        widget.comms.endDateTimeR = results[0]!;
      }
    });
    _fetchDataRec();
    reconversion.clear();
  }

  Widget averageDotationCard() {
    var somme = 0.0;
    var average = 0;
    for (var i = 0; i < reconversion.length; i++) {
      somme += reconversion[i].reconversion!;
    }
    average = (somme == 0 ? 0 : somme / reconversion.length).toInt();

    return Card(
      elevation: 5,
      child: ClipPath(
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: philMainColor, width: 5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Moyenne de Reconversion de ${widget.comms.nomCommerciaux}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${NumberFormat("#,###,### CFA").format(average)}/jours",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.star, color: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  double getMaxDotation() {
    double max = 0;
    if (reconversion.isNotEmpty) {
      max = reconversion[0].reconversion!;
      for (var i = 0; i < reconversion.length; i++) {
        if (reconversion[i].reconversion! > max) {
          max = reconversion[i].reconversion!;
        }
      }
    }
    return max;
  }

  Widget headerCard() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        children: [
          averageDotationCard(),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  String myDate(String formattedString) {
    var day = DateTime.parse(formattedString).day;
    var month = DateTime.parse(formattedString).month;
    var year = DateTime.parse(formattedString).year;
    return "$day-$month-$year";
  }

  @override
  bool get wantKeepAlive => true;
}