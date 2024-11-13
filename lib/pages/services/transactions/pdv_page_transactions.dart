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
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;



class PagePdvTransactions extends StatefulWidget  {
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
          onPressed: ()
          {
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
             if(listTransaction.isNotEmpty)
               {
                 generatePdfAndShare(context);
               }
             else{
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
        title:  const Text("Transactions"),
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
            for(var element in r)
            {
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
      return Center(
        child: Column(
          children: [
            const Text("Nous n'avons pas pu contacter le serveur"),
            TextButton(
              child: const Text("Veuillez réessayer", style: TextStyle(color: Colors.green),), onPressed: () {
              setState(() {
                _fetchTransactions();
              });
            },),
          ],
        ),
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
  Widget transaction(TransactionsPdv tr)
  {

    Color bandColor = Colors.blue;
    if((tr.frmsisdn!) == widget.pdv.numeroFlooz)
    {
      bandColor = philMainColor;
    }
    else if((tr.frmsisdn!) == 22897391919)
    {
      bandColor = Colors.red;
    }
    else if((tr.frmsisdn!) != 22897391919 && (tr.frmsisdn!) != widget.pdv.numeroFlooz)
    {
      bandColor = Colors.grey;
    }

    return
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Coins arrondis pour la Card
        ),
        elevation: 8, // Ajustez l'élévation pour plus de profondeur
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
                "${tr.type == 'CSIN' ? 'DÉPÔT' : 'RETRAIT'}\nMontant: ${NumberFormat("#,###,### CFA").format(tr.amount)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Texte en gras pour le titre
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10.0), // Espacement entre le titre et le sous-titre
                child: Text(
                  "De ${tr.fr_pos_name.toString() == widget.pdv.commercial ? "MOI" : tr.fr_pos_name} à ${ tr.to_pos_name.toString() == widget.pdv.commercial ? "MOI" : tr.to_pos_name} \nCommission générée: ${NumberFormat("#,###,### CFA").format(tr.pos_commission)}\n\nDate: ${myDate(tr.timestamp)}"
                      "\nRéférence (ID): ${tr.id}",
                  style: const TextStyle(
                    color: Colors.black54, // Couleur de texte plus douce pour le sous-titre
                  ),
                ),
              ),
            ),
          ),
        ),
      );


  }

  datePicker() async{
    List<DateTime> dates = [widget.pdv.startDateTimeT!,  ];
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
        widget.pdv.startDateTimeT = results[0]!;
        widget.pdv.endDateTimeT = results[1]!;
      }else{
        widget.pdv.startDateTimeT = results[0]!;
        widget.pdv.endDateTimeT = results[0]!;
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



  void generatePdfAndShare(BuildContext context) async {
    // Create a new PDF document
    final syncfusion.PdfDocument document = syncfusion.PdfDocument();
    const int rowsPerPage = 100;
    int totalCommission = 0;

    // Define cell styles
    final syncfusion.PdfStringFormat cellFormat = syncfusion.PdfStringFormat(
      alignment: syncfusion.PdfTextAlignment.center,
      lineAlignment: syncfusion.PdfVerticalAlignment.middle,
    );

    final syncfusion.PdfFont headerFont = syncfusion.PdfStandardFont(syncfusion.PdfFontFamily.helvetica, 12, style: syncfusion.PdfFontStyle.bold);
    final syncfusion.PdfFont cellFont = syncfusion.PdfStandardFont(syncfusion.PdfFontFamily.helvetica, 10);

    // Add the header with company info and logo
    final ByteData data = await rootBundle.load('assets/logo/phil.jpg');
    final List<int> imageData = data.buffer.asUint8List();
    final syncfusion.PdfBitmap image = syncfusion.PdfBitmap(imageData);

    // Variable to be included in the title
    for (int i = 0; i < listTransaction.length; i += rowsPerPage) {
      // Add a page to the document
      final syncfusion.PdfPage page = document.pages.add();
      final syncfusion.PdfGraphics graphics = page.graphics;
      final syncfusion.PdfGrid grid = syncfusion.PdfGrid();

      if (i == 0) {
        // Add header content for the first page only
        graphics.drawImage(image, const Rect.fromLTWH(0, 0, 50, 50));

        graphics.drawString(
          'Nom du point: ${widget.pdv.nomDuPoint}\n'
              'Numéro: ${widget.pdv.numeroFlooz ?? 'Non renseigné'}\n'
              'Commercial: ${widget.pdv.commercial ?? 'Non renseigné'}',
          syncfusion.PdfStandardFont(syncfusion.PdfFontFamily.helvetica, 12),
          bounds: const Rect.fromLTWH(60, 0, 500, 50),
        );

        // Draw the title
        graphics.drawString(
          "Transactions du ${widget.pdv.startDateTimeT == widget.pdv.endDateTimeT ?
          '${widget.pdv.startDateTimeT!.day}-${widget.pdv.startDateTimeT!.month}-${widget.pdv.startDateTimeT!.year}' :
          '${widget.pdv.startDateTimeT!.day}-${widget.pdv.startDateTimeT!.month}-${widget.pdv.startDateTimeT!.year} au ${widget.pdv.endDateTimeT!.day}-${widget.pdv.endDateTimeT!.month}-${widget.pdv.endDateTimeT!.year}'}",
          syncfusion.PdfStandardFont(syncfusion.PdfFontFamily.helvetica, 13, style: syncfusion.PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(0, 60, 0, 40),
        );
      }

      // Add the columns
      grid.columns.add(count: 8);

      // Add the headers
      final syncfusion.PdfGridRow headerRow = grid.headers.add(1)[0];
      headerRow.cells[0].value = 'Type';
      headerRow.cells[1].value = 'Solde avant Tr';
      headerRow.cells[2].value = 'Montant';
      headerRow.cells[3].value = 'Solde après Tr';
      headerRow.cells[4].value = 'Date';
      headerRow.cells[5].value = 'Expéditeur';
      headerRow.cells[6].value = 'Destinataire';
      headerRow.cells[7].value = 'Commission';

      // Apply styles to header
      for (int j = 0; j < headerRow.cells.count; j++) {
        headerRow.cells[j].style = syncfusion.PdfGridCellStyle(
          font: headerFont,
          format: cellFormat,
        );
      }

      // Add the transactions
      for (int j = i; j < listTransaction.length; j++) {
        final transaction = listTransaction[j];
        final syncfusion.PdfGridRow row = grid.rows.add();
        row.cells[0].value = transaction.type == 'CSIN' ? 'DÉPÔT' : 'RETRAIT';
        row.cells[1].value = NumberFormat("#,###,### CFA").format(transaction.pos_balance_before).toString();
        row.cells[2].value = NumberFormat("#,###,### CFA").format(transaction.amount).toString();
        row.cells[3].value = NumberFormat("#,###,### CFA").format(transaction.pos_balance_after).toString();
        row.cells[4].value = myDate(transaction.timestamp);
        row.cells[5].value = transaction.frmsisdn == widget.pdv.numeroFlooz ? 'MOI' : transaction.frmsisdn.toString();
        row.cells[6].value = transaction.tomsisdn == widget.pdv.numeroFlooz ? 'MOI' : transaction.tomsisdn.toString();
        row.cells[7].value = NumberFormat("#,###,### CFA").format(transaction.pos_commission);

        totalCommission += transaction.pos_commission!;

        // Apply styles to cells
        for (int k = 0; k < row.cells.count; k++) {
          row.cells[k].style = syncfusion.PdfGridCellStyle(
            font: cellFont,
            format: cellFormat,
          );
        }
      }

      if (i + rowsPerPage >= listTransaction.length) {
        final syncfusion.PdfGridRow totalRow = grid.rows.add();
        totalRow.cells[0].value = 'Total';
        totalRow.cells[0].columnSpan = 5;  // Merge the first 5 cells
        totalRow.cells[7].value = NumberFormat("#,###,### CFA").format(totalCommission).toString();

        // Apply styles to total row
        for (int k = 0; k < totalRow.cells.count; k++) {
          totalRow.cells[k].style = syncfusion.PdfGridCellStyle(
            font: headerFont,
            format: cellFormat,
          );
        }
      }

      // Calculate the starting bounds for the grid on each page
      double gridStartY = (i == 0) ? 110 : 0;
      grid.draw(page: page, bounds: Rect.fromLTWH(0, gridStartY, page.getClientSize().width, page.getClientSize().height - gridStartY));
    }

    // Save the document
    try {
      List<int> bytes = document.saveSync();
      document.dispose();

      // Write the document to a file
      final String path = (await getApplicationDocumentsDirectory()).path;
      final String fileName = '$path/Transactions_de_${widget.pdv.nomDuPoint}.pdf';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);

      // Share the PDF
      sharePdf(fileName);

      // Show a dialog to confirm success
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Succès'),
            content: const Text('PDF généré avec succès.'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: Text('Erreur lors de la génération du PDF: $e'),
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
  }

  void sharePdf(String fileName) async {
    await Share.shareXFiles([XFile(fileName)]);  }

}
