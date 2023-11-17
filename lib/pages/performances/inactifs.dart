import 'package:flutter/material.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/pdvs.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/accueil/details_point.dart';
import 'package:phil_mobile/provider/queries_provider.dart';

class PageInactifs extends StatefulWidget {
  const PageInactifs({Key? key, required this.comms}) : super(key: key);

  final Comms comms;

  @override
  State<PageInactifs> createState() => _PageInactifsState();
}

class _PageInactifsState extends State<PageInactifs> {
  List<PointDeVente> inactivite = [];
  late final QueriesProvider _provider;
  bool gettingInactifs = true;
  bool gotInactifsError = false;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async {
    _provider = await QueriesProvider.instance;
    fetchInactifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.yellow,
            ),
            SizedBox(width: 10),
            Text(
              "Mes Inactifs",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Center(
            child: Text(
              "Inactifs du mois de ${_getMonthName(DateTime.now().month)}", // Utilisation de la fonction _getMonthName pour obtenir le mois en français
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            child: _buildInactifs(),
          ),
        ],
      ),
    );
  }

  _buildInactifs() {
    if(gettingInactifs)
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
    if(gotInactifsError){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Nous n'avons pas pu contacter le serveur"),
          TextButton(
            child: Text("Veuillez réessayer", style: TextStyle(color: Colors.green),), onPressed: () {
            setState(() {
              inactivite.clear();
              fetchInactifs();
            });
          },),
        ],
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: inactivite.length,
      itemBuilder: (BuildContext, index) {
        return _pdvs(inactivite[index]);
      },
    );
  }

  _pdvs(PointDeVente pdvs) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
          border: Border.all(
            color: Colors.blueGrey,
          ),
        ),
        child: ListTile(
          onTap: () {
            nextPage(context, PageDetailsPdv(pdv: pdvs));
          },
          leading: Icon(
            Icons.store,
            color: Colors.blueGrey,
          ),
          title: Text(
            "${pdvs.numeroFlooz.toString()}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          subtitle: Text(
            "${pdvs.nomDuPoint}",
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchInactifs() async {
    setState(() {
      gotInactifsError = false;
      gettingInactifs = true;
    });
    await _provider.fetchInactifsZone(
      cmId: widget.comms.id,
      startDate: DateTime.now().month - 2,
      secure: false,
      onSuccess: (cms) {
        setState(() {
          for (var element in cms) {
            inactivite.add(PointDeVente.MapPdvs(element));
          }
          gotInactifsError = false;
          gettingInactifs = false;
        });
      },
      onError: (error) {
        setState(() {
          gotInactifsError = true;
          gettingInactifs = false;
        });
      },
    );
  }

  String _getMonthName(int monthNumber) {
    const monthNames = [
      "janvier", "février", "mars", "avril", "mai", "juin",
      "juillet", "août", "septembre", "octobre", "novembre", "décembre"
    ];
    return monthNames[monthNumber - 1];
  }
}
