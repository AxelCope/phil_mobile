import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/caPdv.dart';
import 'package:phil_mobile/models/pdvs.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/queries_provider.dart';

class PageDetailsPdv extends StatefulWidget {
  const PageDetailsPdv({super.key, required this.pdv});

  final PointDeVente pdv;
  @override
  State<PageDetailsPdv> createState() => _PageDetailsPdvState();
}

class _PageDetailsPdvState extends State<PageDetailsPdv> {

  DateTime month = DateTime.now();
  List<ChiffreAffaire> listCA = [];
  bool gotCa = false;
  bool gotCaError = true;

  late final QueriesProvider _provider;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
    getCA();
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
        title: const Text("Détails du point"),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 18.0, right: 18, top: 45, bottom: 40),
            decoration: BoxDecoration(
              color: Colors.grey.shade100
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.pdv.nomDuPoint!, style: const TextStyle(fontSize: 25),),
                const SizedBox(height: 10,),
                Text(widget.pdv.numeroFlooz!.toString(), style: const TextStyle(fontSize: 21),),
                const SizedBox(height: 10,),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18, top: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                     Image.asset("assets/income.png", width: 30, color: philMainColor,),
                    const SizedBox(width: 10,),
                    _getCa()

                  ],
                ),
                const SizedBox(height: 30,),
                Text("Profile: ${widget.pdv.profil}", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Text("Numero du propirétaire: ${widget.pdv.numeroProprietaireDuPdv} ( ${widget.pdv.sexeDuGerant})", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),

                Text("Type d'activité: ${widget.pdv.typeDactivite}", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: hexToColor('#f5f5f5'),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Region: ${widget.pdv.region}", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 20,),
                            Text("Prefecture: ${widget.pdv.prefecture}", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 20,),
                            Text("Commune: ${widget.pdv.commune}", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 20,),
                            Text("Canton: ${widget.pdv.canton}", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 20,),
                            Text("Quartier: ${widget.pdv.quartier}", style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: ()async{
                            double dl = double.parse(widget.pdv.longitude!);
                            double dL = double.parse(widget.pdv.latitude!);

                            final availableMaps = await MapLauncher.installedMaps;
                            print(availableMaps);

                            await availableMaps.first.showDirections(
                              destination: Coords(dL, dl),
                            );

                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(13.0),
                            child: Column(
                              children: [
                                Text("Emplacement"),
                                Icon(Icons.map_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                Text("Localisation:  ${widget.pdv.localisation}", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Text("NIF:  ${widget.pdv.nif ?? "Non indiqué" }", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Text("Régime fiscal:  ${widget.pdv.regimeFiscal ?? "Non indiqué" }", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Text("Support de visibilité:  ${widget.pdv.supportDeVisibiliteChevaletPotenceAutocollant ?? "Non indiqué" }", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Text("Etat de la visibilité:  ${widget.pdv.etatDuSupportDeVisibiliteBonMauvais ?? "Non indiqué" }", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),


              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void>  getCA() async {
    setState(() {
      gotCaError = false;
      gotCa = false;
    });
    await _provider.getCA(
      secure: false,
      pdv: widget.pdv.numeroFlooz,
      month: month.month-2,
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            listCA.add(ChiffreAffaire.MapChiffresaffaire(element));
          }
          gotCa = true;
          gotCaError = false;
        });
      },
      onError: (e) {
        setState(() {
          gotCaError = true;
          gotCa = true;
          print(e);
        });
      },
    );
  }

  _ca()
  {
     double ca = 0;
    if(listCA.isNotEmpty)
      {
        ca = listCA[0].chiffreAffaire!;
        return ca;
      }
    return ca;
  }

  _getCa()
  {
    if(!gotCa)
    {
      return const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeAlign: 1,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }
    if(gotCaError)
      {
        return Center(
          child: Column(
            children: [

              TextButton(
                child: const Text("Réessayer", style: TextStyle(color: Colors.green),), onPressed: () {
                setState(() {
                  listCA.clear();
                  getCA();
                });
              },),
            ],
          ),
        );
      }
    return Text("${_ca() ?? 0} CFA", style: const TextStyle(fontWeight: FontWeight.bold),);
  }

}
