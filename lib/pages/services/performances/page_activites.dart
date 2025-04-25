import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/models/model_chiffre_daffaire.dart';
import 'package:phil_mobile/models/model_segmentation.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:phil_mobile/widget/card.dart';
import 'dart:math' as math;
import 'dart:ui' as ui; // Import pour TextDirection.ltr

class ProgressionObjectif extends StatefulWidget {
  const ProgressionObjectif({super.key, required this.comms});

  final Comms comms;

  @override
  State<ProgressionObjectif> createState() => _ProgressionObjectifState();
}

class _ProgressionObjectifState extends State<ProgressionObjectif> with AutomaticKeepAliveClientMixin {
  List<ChiffreAffaire> commCagnt = [];
  List<ChiffreAffaire> objectifComm = [];
  late final QueriesProvider _provider;
  DateTime date = DateTime.now();
  bool gotObjectif = false;
  bool gotComm = false;
  bool segmentationCheck = true;
  bool segmentationCheckError = false;
  List<Segmentation> zoneA = [];
  List zoneB = [];
  List zoneC = [];
  List zoneD = [];
  List zoneE = [];
  List allZone = [];
  late var allList = [zoneA, zoneB, zoneC, zoneD, zoneE, allZone];

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async {
    _provider = await QueriesProvider.instance;
    objectifsComm();
    getCommission();
    segmentation();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: all(),
      ),
    );
  }

  Widget all() {
    return ListView(
      children: [
        _getCa(),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text("Mes segments", style: TextStyle(fontSize: 21)),
        ),
        allSegments(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _getCa() {
    int obj = 0;
    int comm = 0;
    var rep1 = 0;
    if (!gotObjectif && !gotComm) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 100.0),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          ),
        ),
      );
    }
    if (objectifComm.isNotEmpty && commCagnt.isNotEmpty) {
      obj = objectifComm[0].obj!;
      comm = int.parse(commCagnt[0].comm!);
      rep1 = ((comm / obj) * 100).round();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const Text(
                "Ma progression sur l'objectif du mois",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 70,
                child: Divider(),
              ),
              CustomRadialGauge(
                percentage: (comm / obj).clamp(0.0, 1.0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Commission/Objectif\n",
                        style: TextStyle(fontSize: 19, color: Colors.black),
                      ),
                      TextSpan(
                        text:
                        " ${NumberFormat("###,### CFA").format(comm)} / ${NumberFormat("###,### CFA").format(obj)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> objectifsComm() async {
    setState(() {
      gotObjectif = false;
    });
    await _provider.objectifsbyComm(
      secure: false,
      id: widget.comms.id,
      date: _getMonthName(date.month),
      onSuccess: (r) {
        setState(() {
          for (var element in r) {
            objectifComm.add(ChiffreAffaire.MapObj(element));
          }
          gotObjectif = true;
        });
      },
      onError: (e) {
        setState(() {
          gotObjectif = false;
        });
      },
    );
  }

  Future<void> getCommission() async {
    setState(() {
      gotComm = false;
    });
    await _provider.commissionCommerciaux(
      secure: false,
      cmId: widget.comms.id,
      date: date.month,
      onSuccess: (r) {
        setState(() {
          for (var element in r) {
            commCagnt.add(ChiffreAffaire.MapComm(element));
          }
          gotComm = true;
        });
      },
      onError: (e) {
        setState(() {
          gotComm = false;
        });
      },
    );
  }

  Future<void> _refresh() async {
    setState(() {
      commCagnt.clear();
      objectifComm.clear();
      zoneA.clear();
      zoneB.clear();
      zoneC.clear();
      zoneD.clear();
      zoneE.clear();
      objectifsComm();
      segmentation();
      getCommission();
    });
  }

  Widget allSegments() {
    if (segmentationCheck) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 200.0),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        sgA(),
        const SizedBox(height: 10),
        sgB(),
        const SizedBox(height: 10),
        sgC(),
        const SizedBox(height: 10),
        sgD(),
        const SizedBox(height: 10),
        sgE(),
      ],
    );
  }

  Widget sgA() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CardHighlight(
        header: const Text(
          "Voir les points de vente de ce segment",
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        codeSnippet: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: zoneA.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneA[index]);
          },
        ),
        child: Text(
          "Segments A: ${zoneA.length} points de ventes",
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget sgB() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CardHighlight(
        header: const Text(
          "Voir les points de vente de ce segment",
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        codeSnippet: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: zoneB.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneB[index]);
          },
        ),
        child: Text(
          "Segments B: ${zoneB.length} points de ventes",
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget sgC() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CardHighlight(
        header: const Text(
          "Voir les points de vente de ce segment",
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        codeSnippet: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: zoneC.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneC[index]);
          },
        ),
        child: Text(
          "Segments C: ${zoneC.length} points de ventes",
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget sgD() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CardHighlight(
        header: const Text(
          "Voir les points de vente de ce segment",
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        codeSnippet: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: zoneD.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneD[index]);
          },
        ),
        child: Text(
          "Segments D: ${zoneD.length} points de ventes",
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget sgE() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CardHighlight(
        header: const Text(
          "Voir les points de vente de ce segment",
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        codeSnippet: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: zoneE.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneE[index]);
          },
        ),
        child: Text(
          "Segments E: ${zoneE.length} points de ventes",
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget segment(Segmentation dt) {
    var formatter = NumberFormat("#,###,###");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "(${dt.id}) ${dt.nomPoints} : ${formatter.format(dt.somme)} CFA",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> segmentation() async {
    setState(() {
      segmentationCheck = true;
    });
    await _provider.SegmentationParComm(
      cmId: widget.comms.id,
      date: DateTime.now().month,
      secure: false,
      onSuccess: (cms) {
        for (var element in cms) {
          var seg = double.parse(element['sommedotes']);
          allZone.add(Segmentation.mapSegmentation(element));

          seg > 10000000
              ? zoneA.add(Segmentation.mapSegmentation(element))
              : (null);
          seg >= 5000000 && seg <= 10000000
              ? zoneB.add(Segmentation.mapSegmentation(element))
              : (null);
          seg >= 1000000 && seg <= 5000000
              ? zoneC.add(Segmentation.mapSegmentation(element))
              : (null);
          seg >= 1 && seg <= 1000000
              ? zoneD.add(Segmentation.mapSegmentation(element))
              : (null);
          seg == 0 ? zoneE.add(Segmentation.mapSegmentation(element)) : (null);
        }
        setState(() {
          segmentationCheck = false;
        });
      },
      onError: (error) {
        setState(() {
          segmentationCheck = true;
        });
      },
    );
  }

  String _getMonthName(int monthNumber) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return monthNames[monthNumber - 1].toUpperCase();
  }

  @override
  bool get wantKeepAlive => true;
}

class CustomRadialGauge extends StatelessWidget {
  final double percentage;

  const CustomRadialGauge({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: CustomPaint(
        painter: RadialGaugePainter(percentage: percentage),
      ),
    );
  }
}

class RadialGaugePainter extends CustomPainter {
  final double percentage;

  RadialGaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dessiner l'arrière-plan
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Dessiner la progression
    final progressPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    double sweepAngle = (2 * math.pi * percentage).clamp(0, 2 * math.pi);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Début à 12h
      sweepAngle,
      false,
      progressPaint,
    );

    // Dessiner le texte
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(percentage * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr, // Correction ici
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}