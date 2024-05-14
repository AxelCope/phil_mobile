import 'package:flutter/material.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/model_point_de_ventes.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/accueil/page_detail_pdvs.dart';
import 'package:phil_mobile/pages/consts.dart';
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
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              previousPage(context);
            }
        ),
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: philMainColor,
        title: const Row(
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
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Inactifs du mois de ${_getMonthName(DateTime.now().month)}", // Utilisation de la fonction _getMonthName pour obtenir le mois en français
              style: const TextStyle(
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
          const Text("Nous n'avons pas pu contacter le serveur"),
          TextButton(
            child: const Text("Veuillez réessayer", style: TextStyle(color: Colors.green),), onPressed: () {
            setState(() {
              inactivite.clear();
              fetchInactifs();
            });
          },),
        ],
      );
    }
    if(inactivite.isEmpty)
      {
        print("emptu");
        return Center(
          child: Text("Vous n'avez pas d'inactifs pour ce mois", style: TextStyle(color: Colors.black),),
        );
      }
    print(inactivite);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: inactivite.length,
      itemBuilder: (context, index) {
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
          leading: const Icon(
            Icons.store,
            color: Colors.blueGrey,
          ),
          title: Text(
            pdvs.numeroFlooz.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          subtitle: Text(
            "${pdvs.nomDuPoint}",
            style: const TextStyle(
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
      startDate: DateTime.now().month,
      secure: false,
      onSuccess: (cms) {
        setState(() {
          for (var element in cms) {
            inactivite.add(PointDeVente.MapPdvs(element));
            print(element);
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
