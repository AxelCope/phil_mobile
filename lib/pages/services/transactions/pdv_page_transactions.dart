import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/model_point_de_ventes.dart';
import 'package:phil_mobile/models/model_transaction_pdv.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PagePdvTransactions extends StatefulWidget {
  const PagePdvTransactions({super.key, required this.pdv});

  final PointDeVente pdv;
  @override
  State<PagePdvTransactions> createState() => _PagePdvTransactionsState();
}

class _PagePdvTransactionsState extends State<PagePdvTransactions> {
  late final QueriesProvider _provider;
  final ScrollController _scrollController = ScrollController();
  bool gotData = true;
  bool getDataError = false;
  List<TransactionsPdv> listTransaction = [];

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
          onPressed: () {
            previousPage(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              datePicker();
            },
            icon: const Icon(Icons.calendar_month_sharp),
          ),
          IconButton(
            onPressed: () {
              if (listTransaction.isNotEmpty) {
                generatePdfAndShare(context);
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Erreur'),
                      content: const Text('Aucune transaction trouvée'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
        centerTitle: true,
        title: Text(
          "Total: ${NumberFormat("#,###,### CFA").format(commTotal())}",
          style: const TextStyle(fontSize: 13),
        ),
      ),
      body: allTransactions(),
    );
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      gotData = true;
      getDataError = false;
    });
    _provider.transaction_pdv(
      Sdate: widget.pdv.startDateTimeT.toString(),
      Edate: widget.pdv.endDateTimeT.toString(),
      id: widget.pdv.numeroFlooz,
      secure: false,
      onSuccess: (r) {
        setState(() {
          for (var element in r) {
            listTransaction.add(TransactionsPdv.MapTransact(element));
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
      },
    );
  }

  Widget allTransactions() {
    if (gotData) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 200.0),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(color: Colors.green),
          ),
        ),
      );
    }
    if (getDataError) {
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
                  _fetchTransactions();
                });
              },
            ),
          ],
        ),
      );
    }
    if (listTransaction.isEmpty) {
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
        itemBuilder: (context, index) {
          return transaction(listTransaction[index]);
        },
      ),
    );
  }

  Widget transaction(TransactionsPdv tr) {
    Color bandColor = Colors.blue; // Couleur par défaut
    if (tr.frmsisdn == widget.pdv.numeroFlooz) {
      bandColor = philMainColor;
    } else if (tr.frmsisdn == '22897391919') { // Conversion en String pour correspondre au type String?
      bandColor = Colors.red;
    } else if (tr.type == 'GIVE') {
      bandColor = Colors.red; // Bordure rouge pour Dotation
    } else if (tr.frmsisdn != '22897391919' && tr.frmsisdn != widget.pdv.numeroFlooz) {
      bandColor = Colors.grey;
    }

    // Fonction utilitaire pour formater un montant, gérant les nulls
    String formatAmount(num? value) {
      return value != null ? NumberFormat("#,###,### CFA").format(value) : "0 CFA";
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              left: BorderSide(color: bandColor, width: 5),
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            title: Text(
              "${tr.type == 'CashIn' ? 'DÉPÔT' : tr.type == 'GIVE' ? 'Dotation' : 'RETRAIT'}\nMontant: ${formatAmount(tr.amount)}",              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "De ${tr.frmsisdn.toString() == widget.pdv.numeroFlooz ? widget.pdv.nomDuPoint : tr.frmsisdn} "
                    "à ${tr.tomsisdn.toString() == widget.pdv.numeroFlooz ? widget.pdv.nomDuPoint : tr.tomsisdn} "
                    "\nCommission générée: ${formatAmount(tr.pos_commission)}\n\n"
                    "Date: ${myDate(tr.timestamp)}"
                    "\n\nSolde:"
                    "\npre-transaction: ${formatAmount(tr.pos_balance_before)}"
                    "\npost-transaction: ${formatAmount(tr.pos_balance_after)}"
                    "\n\nRéférence (ID): ${tr.id}",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  datePicker() async {
    List<DateTime> dates = [widget.pdv.startDateTimeT!];
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
        widget.pdv.startDateTimeT = results[0]!;
        widget.pdv.endDateTimeT = results[1]!;
      } else {
        widget.pdv.startDateTimeT = results[0]!;
        widget.pdv.endDateTimeT = results[0]!;
      }
    });
    _fetchTransactions();
    listTransaction.clear();
  }

  String myDate(formattedString) {
    var day = DateTime.parse(formattedString).day;
    var month = DateTime.parse(formattedString).month;
    var year = DateTime.parse(formattedString).year;
    var hour = DateTime.parse(formattedString).hour;
    var minute = DateTime.parse(formattedString).minute;

    return "$day-$month-$year $hour:$minute";
  }

  double commTotal() {
    double total = 0.0;
    for (var cm in listTransaction) {
      total += (cm.pos_commission ?? 0);
    }
    return total;
  }

  void generatePdfAndShare(BuildContext context) async {
    final pw.Document document = pw.Document();
    final ByteData data = await rootBundle.load('assets/logo/phil.jpg');
    final pw.MemoryImage image = pw.MemoryImage(data.buffer.asUint8List());

    final pw.Font headerFont = pw.Font.helveticaBold();
    final pw.Font cellFont = pw.Font.helvetica();
    final NumberFormat formatter = NumberFormat("#,###,### CFA");

    // Fonction utilitaire pour formater un montant, gérant les nulls
    String formatAmount(num? value) {
      return value != null ? formatter.format(value) : '0 CFA';
    }

    int totalCommission = listTransaction.fold(0, (prev, t) => prev + (t.pos_commission ?? 0));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Génération du PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Veuillez patienter pendant la génération du PDF...'),
              const SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        maxPages: 100,
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(image, width: 50, height: 50),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nom du point: ${widget.pdv.nomDuPoint}',
                      style: pw.TextStyle(font: headerFont, fontSize: 12),
                    ),
                    pw.Text(
                      'Numéro: ${widget.pdv.numeroFlooz ?? 'Non renseigné'}',
                      style: pw.TextStyle(font: headerFont, fontSize: 12),
                    ),
                    pw.Text(
                      'Commercial: ${widget.pdv.commercial ?? 'Non renseigné'}',
                      style: pw.TextStyle(font: headerFont, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Transactions du ${widget.pdv.startDateTimeT == widget.pdv.endDateTimeT ? '${widget.pdv.startDateTimeT!.day}-${widget.pdv.startDateTimeT!.month}-${widget.pdv.startDateTimeT!.year}' : '${widget.pdv.startDateTimeT!.day}-${widget.pdv.startDateTimeT!.month}-${widget.pdv.startDateTimeT!.year} au ${widget.pdv.endDateTimeT!.day}-${widget.pdv.endDateTimeT!.month}-${widget.pdv.endDateTimeT!.year}'}",
              style: pw.TextStyle(font: headerFont, fontSize: 13),
            ),
            pw.SizedBox(height: 10),
            // Table
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey700),
              headerStyle: pw.TextStyle(font: headerFont, fontSize: 10),
              cellStyle: pw.TextStyle(font: cellFont, fontSize: 8),
              cellAlignment: pw.Alignment.center,
              headers: [
                'Type',
                'Solde avant Tr',
                'Montant',
                'Solde après Tr',
                'Date',
                'Expéditeur',
                'Destinataire',
                'Commission',
              ],
              data: listTransaction.map((t) {
                return [
                  t.type == 'CashIn' ? 'DÉPÔT' : t.type == 'GIVE' ? 'Dotation' : 'RETRAIT',
                  formatAmount(t.pos_balance_before),
                  formatAmount(t.amount),
                  formatAmount(t.pos_balance_after),
                  myDate(t.timestamp),
                  t.frmsisdn == widget.pdv.numeroFlooz ? 'MOI' : t.frmsisdn?.toString() ?? 'Inconnu',
                  t.tomsisdn == widget.pdv.numeroFlooz ? 'MOI' : t.tomsisdn?.toString() ?? 'Inconnu',
                  formatAmount(t.pos_commission),
                ];
              }).toList()
                ..add([
                  'Total',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  formatAmount(totalCommission),
                ]),
            ),
          ];
        },
      ),
    );

    try {
      final String path = (await getApplicationDocumentsDirectory()).path;
      final String fileName = '$path/Transactions_de_${widget.pdv.nomDuPoint}.pdf';
      final File file = File(fileName);
      await file.writeAsBytes(await document.save(), flush: true);

      sharePdf(fileName);

      Navigator.of(context).pop(); // Close the progress dialog

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Succès'),
          content: const Text('PDF généré avec succès.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the progress dialog

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text('Erreur lors de la génération du PDF: $e'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void sharePdf(String fileName) async {
    await Share.shareXFiles([XFile(fileName)]);
  }
}