import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/models/model_givecom.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/provider/queries_provider.dart';

class PageGiveComs extends StatefulWidget {
  const PageGiveComs({super.key, required this.comms});

  final Comms comms;

  @override
  State<PageGiveComs> createState() => _PageGiveComsState();
}

class _PageGiveComsState extends State<PageGiveComs> {
  DateTime date = DateTime.now();
  bool gettingGivecom = true;
  bool gotGivecomError = false;
  List<GiveCom> listGivecom = [];
  late final QueriesProvider _provider;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async {
    _provider = await QueriesProvider.instance;
    getGiveCom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Total givecom: ${NumberFormat("#,###,###,### CFA").format(givecomTotalAvecFrais())}",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        )

      ),
      body:
      ListView(
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: givecomTable(),
            ),
          )
           ,
        ],
      ),

    );
  }

  givecomTable() {
    if(gettingGivecom) {
      return const Padding(
        padding: EdgeInsets.only(top:200.0),
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      );
    }
    if (gotGivecomError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Nous n'avons pas pu contacter le serveur"),
            TextButton(
              child: const Text(
                "Veuillez réessayer",
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                setState(() {
                  listGivecom.clear();
                  getGiveCom();
                });
              },
            ),
          ],
        ),
      );
    }
    if(listGivecom.isEmpty)
      {
        return const Padding(
          padding: EdgeInsets.only(top:200.0),
          child: Center(
            child: Text("Vous n'avez aucun givecom pour ce mois"),
          ),
        );
      }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.green), // Couleur de la première ligne
        dataRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.white), // Couleur des lignes de données
        dataTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.black),
        headingTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey),
        ),
        columns: const [
          DataColumn(label: Text("Montants", textAlign: TextAlign.center)),
          DataColumn(label: Text("Frais", textAlign: TextAlign.center)),
          DataColumn(label: Text("Nom pdvs", textAlign: TextAlign.center)),
        ],
        rows: listGivecom.map((data) {
          return DataRow(cells: [
            DataCell(
              Text(
                NumberFormat("#,###,###,### CFA").format(data.montant),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red, // Couleur rouge pour les frais
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(
              Text(
                NumberFormat("-#,###,###,#### CFA").format(data.montant! * 0.001),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red, // Couleur rouge pour les frais
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(
              Text(
                "${data.pdvs!.toString()} (${data.numero.toString()})",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
                softWrap: true,

              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }


  Future<void> getGiveCom() async {
    setState(() {
      gettingGivecom = true;
      gotGivecomError = false;
    });
    await _provider.giveCOmDistinct(
      secure: false,
      commId: widget.comms.id,
      date: date.month,
      onSuccess: (r) {
        setState(() {
          for (var element in r) {
            listGivecom.add(GiveCom.mapGivecom(element));
          }
          gettingGivecom = false;
          gotGivecomError = false;
        });
      },
      onError: (e) {
        setState(() {
          gotGivecomError = true;
          gettingGivecom = false;
        });
      },
    );
  }

  double givecomTotalAvecFrais() {
    double total = 0.0;
    for (var gv in listGivecom) {
      total += (gv.montant ?? 0.0) * 0.001;
    }
    return total;
  }

}
