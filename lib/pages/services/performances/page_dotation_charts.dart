import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/models/model_dotations.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/DotationProvider.dart';

class DetailsDotations extends StatefulWidget {
  const DetailsDotations({
    Key? key,
    required this.comms,
  }) : super(key: key);

  final Comms comms;

  @override
  State<DetailsDotations> createState() => _DetailsDotationsState();
}

class _DetailsDotationsState extends State<DetailsDotations> with AutomaticKeepAliveClientMixin {
  List<Dotations> listDotations = [];
  bool gotData = true;
  bool getDataError = false;
  late DotationProvider dv;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    dv = await DotationProvider.instance;
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: buildWidget(),
    );
  }

  String myDate(formattedString) {
    var day = DateTime.parse(formattedString).day;
    var month = DateTime.parse(formattedString).month;
    var year = DateTime.parse(formattedString).year;
    return "$day-$month-$year";
  }

  int getMaxDotation() {
    int max = 0;
    if (listDotations.isNotEmpty) {
      max = listDotations[0].dotations!;
      for (var i = 0; i < listDotations.length; i++) {
        if (listDotations[i].dotations! > max) {
          max = listDotations[i].dotations!;
        }
      }
    }
    return max;
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
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(philMainColor),
                ),
                child: const Text("Actualiser la page", style: TextStyle(color: Colors.black)),
                onPressed: () {
                  _fetchData();
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
                  listDotations.sort((a, b) {
                    final aDate = DateTime.parse(a.dates!);
                    final bDate = DateTime.parse(b.dates!);
                    return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
                  });
                });
              },
            ),
            DataColumn(
              label: Text(
                'Nombre de dotations',
                style: TextStyle(fontWeight: FontWeight.bold, color: philMainColor),
              ),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  listDotations.sort((a, b) =>
                  ascending ? a.dotations!.compareTo(b.dotations!) : b.dotations!.compareTo(a.dotations!));
                });
              },
            ),
          ],
          rows: listDotations.map((dotation) {
            final isMax = dotation.dotations == maxDotation && maxDotation != 0;
            return DataRow(
              color: isMax
                  ? MaterialStateProperty.all(philMainColor.withOpacity(0.1))
                  : null,
              cells: [
                DataCell(
                  Text(
                    myDate(dotation.dates!),
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
                        NumberFormat("#,###,###").format(dotation.dotations),
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

  Widget averageDotationCard() {
    var somme = 0.0;
    var average = 0;
    for (var i = 0; i < listDotations.length; i++) {
      somme += listDotations[i].dotations!;
    }
    average = (somme == 0 ? 0 : somme / listDotations.length).toInt();

    return Card(
      elevation: 5,
      child: ClipPath(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: philMainColor, width: 5),
            ),
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
                      "Moyenne de Dotations de ${widget.comms.nomCommerciaux}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$average/jours",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.orange,
                        ),
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

  Widget headerCard() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        children: [
          averageDotationCard(),
        ],
      ),
    );
  }

  Widget buildWidget() {
    return ListView(
      children: [
        headerCard(),
        chart(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: philMainColor,
          ),
          onPressed: () {
            datePicker();
          },
          child: const Text(
            'Selectionner la plage de dates',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  datePicker() async {
    List<DateTime> dates = [widget.comms.startDateTime!];
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
        widget.comms.startDateTime = results[0]!;
        widget.comms.endDateTime = results[1]!;
      } else {
        widget.comms.startDateTime = results[0]!;
        widget.comms.endDateTime = results[0]!;
      }
    });
    _fetchData();
    listDotations.clear();
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
          listDotations = r;
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
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}