import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
 import 'package:phil_mobile/models/caPdv.dart';
import 'package:phil_mobile/models/segmentation.dart';
 import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/performances/segmentation.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:phil_mobile/widget/card.dart';

class ProgressionObjectif extends StatefulWidget {
  const ProgressionObjectif({super.key,required this.comms
  });

  final Comms comms;

  @override
  State<ProgressionObjectif> createState() => _ProgressionObjectifState();
}

class _ProgressionObjectifState extends State<ProgressionObjectif> with AutomaticKeepAliveClientMixin{
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
  List Allzone = [];
  late var allList = [zoneA, zoneB, zoneC, zoneD, zoneE, Allzone];

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
    objectifsComm();
    getCommission();
    segmentation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: all()
        ),
      ),
    );
  }


  Widget all()
  {
  return ListView(
  children: [
  _getCa(),
    SizedBox(height: 10,),
    Text("Mes segments", style: TextStyle(fontSize: 21),),
    allSegments(),
    SizedBox(height: 10,),
  ],
  );
  }

  _getCa()
  {

    int obj = 0;
    int comm = 0;
    var rep1 = 0;
    if(!gotObjectif && !gotComm)
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
    if(objectifComm.isNotEmpty && commCagnt.isNotEmpty)
    {
      obj = objectifComm[0].obj!;
      comm = commCagnt[0].comm!;
      rep1 = ((comm / obj) * 100).round();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Stack(
              children: [
                Positioned(
                  child: Text(
                    "${rep1}%",
                    style: TextStyle(fontSize: 20),
                  ),
                  top: 33,
                  left: 30,
                ),
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: (comm / obj).clamp(0.0, 1.0),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ],
            ),
            SizedBox(width: 10,),
            Column(
              children: [
                Text("Commission/Objectif"),
                Text(
                  " ${NumberFormat("###,### CFA").format(comm)} / ${NumberFormat("###,### CFA").format(obj)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            )
          ],
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
      date: 'NOVEMBER',
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            objectifComm.add(ChiffreAffaire.MapObj(element));
            print(element);
          }
          gotObjectif = true;
        });
      },
      onError: (e) {
        setState(() {
          gotObjectif = false;
          print(e);
        });
      },
    );
  }

  Future<void>  getCommission() async {
    setState(() {
      gotComm = false;
    });
    await _provider.commissionCommerciaux(
      secure: false,
      cmId: widget.comms.id,
      date: date.month,
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            commCagnt.add(ChiffreAffaire.MapComm(element));
          }
          gotComm = true;
        });
      },
      onError: (e) {
        setState(() {
          gotComm = false;
          print(e);
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
    if(segmentationCheck)
    {
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
        const SizedBox(width: 50),
        sgB(),
        const SizedBox(width: 50),
        sgC(),
        const SizedBox(width: 50),
        sgD(),
        const SizedBox(width: 50),
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
          physics: NeverScrollableScrollPhysics(),
          itemCount: zoneA.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneA[index]);
          },
        ),
        child: Text(
          "Segments A: ${zoneA.length} points de ventes",
          style: TextStyle(
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
          physics: NeverScrollableScrollPhysics(),
          itemCount: zoneB.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneB[index]);
          },
        ),
        child: Text(
          "Segments B: ${zoneB.length} points de ventes",
          style: TextStyle(
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
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: zoneC.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneC[index]);
          },
        ),
        child: Text(
          "Segments C: ${zoneC.length} points de ventes",
          style: TextStyle(
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
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: zoneD.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneD[index]);
          },
        ),
        child: Text(
          "Segments D: ${zoneD.length} points de ventes",
          style: TextStyle(
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
          physics: NeverScrollableScrollPhysics(),
          itemCount: zoneE.length,
          itemBuilder: (BuildContext c, int index) {
            return segment(zoneE[index]);
          },
        ),
        child: Text(
          "Segments E: ${zoneE.length} points de ventes",
          style: TextStyle(
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
      date: DateTime.now().month - 2,
      secure: false,
      onSuccess: (cms) {
        for (var element in cms) {
          var seg = double.parse(element['sommedotes']);
          Allzone.add(Segmentation.mapSegmentation(element));

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

          print(element);
        }
        setState(() {
          segmentationCheck = false;
          //segmentationCheckError = false;
        });
      },
      onError: (error) {
        setState(() {
          segmentationCheck = true;
          //segmentationCheckError = true;
        });
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
