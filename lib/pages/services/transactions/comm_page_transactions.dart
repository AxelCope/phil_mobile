import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/model_transactions.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PageTransactions extends StatefulWidget {
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
          onPressed: () {
            previousPage(context);
          },
        ),
        actions: [
          Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            richMessage: TextSpan(
              text: 'Légende: \n',
              style: const TextStyle(color: Colors.black),
              children: <InlineSpan>[
                WidgetSpan(child: Icon(Icons.circle, color: philMainColor)),
                const TextSpan(
                  text: 'Représente les dotations que vous effectuez\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const WidgetSpan(child: Icon(Icons.circle, color: Colors.red)),
                const TextSpan(
                  text: 'Représente les dotations du Master\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const WidgetSpan(child: Icon(Icons.circle, color: Colors.grey)),
                const TextSpan(
                  text: 'Représente les reconversions\n',
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
                          onPressed: () => Navigator.of(context).pop(),
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
        title: const Text("Mes transactions", style: TextStyle(fontSize: 15),),
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

  Widget allTransactions() {
    if(gotData) {
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
    if(getDataError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Nous n'avons pas pu contacter le serveur"),
          TextButton(
            child: const Text("Veuillez réessayer", style: TextStyle(color: Colors.green),),
            onPressed: () {
              setState(() {
                _fetchTransactions();
              });
            },
          ),
        ],
      );
    }
    if(listTransaction.isEmpty) {
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
          }
      ),
    );
  }

  Widget transaction(Transactions tr) {
    Color bandColor = Colors.grey; // Default to RECONVERSION
    String transactionLabel = 'RECONVERSION';

    if (tr.frmsisdn == widget.comms.id.toString()) {
      bandColor = philMainColor;
      transactionLabel = 'DOTATION';
    } else if (tr.frmsisdn == '22897391919') {
      bandColor = Colors.red;
      transactionLabel = 'DOTATION MASTER';
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
              "$transactionLabel\nMontant: ${formatAmount(tr.amount)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16.0,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "De ${tr.frmsisdn == widget.comms.id.toString() ? 'MOI' : tr.frmsisdn ?? 'Inconnu'} "
                    "à ${tr.tomsisdn == widget.comms.id.toString() ? 'MOI' : tr.tomsisdn ?? 'Inconnu'}\n"
                    "${tr.status == 'Completed' ? 'Transaction réussie' : 'Transaction échouée/annulée'}\n\n"
                    "Date: ${myDate(tr.timestamp)}\n"
                    "Référence (ID): ${tr.id ?? 'N/A'}",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  datePicker() async {
    List<DateTime> dates = [widget.comms.startDateTimeT!];
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
        widget.comms.startDateTimeT = results[0]!;
        widget.comms.endDateTimeT = results[1]!;
      } else {
        widget.comms.startDateTimeT = results[0]!;
        widget.comms.endDateTimeT = results[0]!;
      }
    });
    listTransaction.clear();
    _fetchTransactions();
  }

  String myDate(String? formattedString) {
    if (formattedString == null) return "Date inconnue";

    try {
      final dt = DateTime.parse(formattedString);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');

      return "$day-$month-$year $hour:$minute";
    } catch (e) {
      return "Format invalide";
    }
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
                      'Commercial: ${widget.comms.nomCommerciaux ?? 'Non renseigné'}',
                      style: pw.TextStyle(font: headerFont, fontSize: 12),
                    ),
                    pw.Text(
                      'Numéro: ${widget.comms.id ?? 'Non renseigné'}',
                      style: pw.TextStyle(font: headerFont, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Transactions du ${widget.comms.startDateTimeT == widget.comms.endDateTimeT ? '${widget.comms.startDateTimeT!.day}-${widget.comms.startDateTimeT!.month}-${widget.comms.startDateTimeT!.year}' : '${widget.comms.startDateTimeT!.day}-${widget.comms.startDateTimeT!.month}-${widget.comms.startDateTimeT!.year} au ${widget.comms.endDateTimeT!.day}-${widget.comms.endDateTimeT!.month}-${widget.comms.endDateTimeT!.year}'}",
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
                'Montant',
                'Date',
                'Expéditeur',
                'Destinataire',
                'Statut',
                'Référence',
              ],
              data: listTransaction.map((t) {
                String transactionLabel = 'RECONVERSION';
                if (t.frmsisdn == widget.comms.id.toString()) {
                  transactionLabel = 'DOTATION';
                } else if (t.frmsisdn == '22897391919') {
                  transactionLabel = 'DOTATION MASTER';
                }
                return [
                  transactionLabel,
                  formatAmount(t.amount),
                  myDate(t.timestamp),
                  t.frmsisdn == widget.comms.id.toString() ? 'MOI' : t.frmsisdn?.toString() ?? 'Inconnu',
                  t.tomsisdn == widget.comms.id.toString() ? 'MOI' : t.tomsisdn?.toString() ?? 'Inconnu',
                  t.status == 'Completed' ? 'Réussie' : 'Échouée/Annulée',
                  t.id?.toString() ?? 'N/A',
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    try {
      final String path = (await getApplicationDocumentsDirectory()).path;
      final String fileName = '$path/Transactions_de_${widget.comms.nicknameCommerciaux ?? 'Commercial'}.pdf';
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