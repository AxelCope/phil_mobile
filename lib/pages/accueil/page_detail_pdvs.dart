import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/model_chiffre_daffaire.dart';
import 'package:phil_mobile/models/model_point_de_ventes.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';


class PageDetailsPdv extends StatefulWidget {
  const PageDetailsPdv({super.key, required this.pdv});

  final PointDeVente pdv;
  @override
  State<PageDetailsPdv> createState() => _PageDetailsPdvState();
}

class _PageDetailsPdvState extends State<PageDetailsPdv> {

  DateTime date = DateTime.now();
  List<ChiffreAffaire> listCA = [];
  List<ChiffreAffaire> soldeList = [];
  List<ChiffreAffaire> commMonth = [];
  List test = [];
  bool gotCa = false;
  bool gotCaError = true;
  bool gotComMonth = false;
  bool gotComMonthError = true;
  bool gotSolde = false;
  bool gotSoldeError = true;




  late final QueriesProvider _provider;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
    getCA();
    getSolde();
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
        actions: [
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                sharePoint();
              }
          ),
        ],
        title: const Text("Détails du point"),
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
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
                     Image.asset("assets/page infos pdvs/income.png", width: 30, color: philMainColor,),
                    const SizedBox(width: 10,),
                    _getCa()
                  ],
                ),
                const SizedBox(height: 15,),
                Row(
                  children: [
                     Image.asset("assets/page infos pdvs/wallet.png", width: 30),
                    const SizedBox(width: 16,),
                    _getSolde(),
                    const SizedBox(width: 8,),
                    Text("(Solde du ${date.year}-${date.month}-${date.day} à 5h)" )
                  ],
                ),
                const SizedBox(height: 30,),
                Text("Profile: ${widget.pdv.profil ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Text("Numero du propirétaire: ${widget.pdv.numeroProprietaireDuPdv ?? '(Non renseigné)'} ( ${widget.pdv.sexeDuGerant ?? '(Non renseigné)'})", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 5,),
               _callPdv(widget.pdv.numeroProprietaireDuPdv),
                const SizedBox(height: 20,),
                Text("Type d'activité: ${widget.pdv.typeDactivite ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
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
                            Text("Region: ${widget.pdv.region ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 20,),
                            Text("Prefecture: ${widget.pdv.prefecture ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 20,),
                            Text("Commune: ${widget.pdv.commune ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 20,),
                            Text("Canton: ${widget.pdv.canton ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 20,),
                            Text("Quartier: ${widget.pdv.quartier ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async{
                          if(widget.pdv.longitude != null && widget.pdv.latitude != null) {
                            double dl = double.parse(widget.pdv.longitude!);
                            double dL = double.parse(widget.pdv.latitude!);
                            final availableMaps =
                                await MapLauncher.installedMaps;
                            await availableMaps.first.showDirections(
                              destination: Coords(dL, dl),
                            );
                          }
                          else{
                            showErrorMessage(context, "Emplacement non renseigné");
                          }
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
                Text("Localisation:  ${widget.pdv.localisation ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
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
      month: date.month,
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
        });
      },
    );
  }

  Future<void>  getSolde() async {
    setState(() {
      gotSolde = false;
      gotSoldeError = false;
    });
    await _provider.solde(
      secure: false,
      id: widget.pdv.numeroFlooz,
      date: '${date.year}-${date.month}-${date.day}',
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            test.add(element);
          }

          gotSolde = true;
          gotSoldeError = false;
        });
      },
      onError: (e) {
        setState(() {
          gotSoldeError = true;
          gotSolde = true;
        });
      },
    );
  }


  Future<void>  getmoisCom() async {
    setState(() {
      gotComMonthError = false;
      gotComMonth = false;
    });
    await _provider.mois_precedents(
      secure: false,
      pdv: widget.pdv.numeroFlooz!,
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            commMonth.add(ChiffreAffaire.MapCommbyMonth(element));
          }

          setState(() {
            gotComMonthError = false;
            gotComMonth = true;
          });

          if(gotComMonth && commMonth.isNotEmpty ) {
            _seeCommMonth();
          }
          else if(gotComMonth && commMonth.isEmpty) {
            _nothing();
          }
        });
      },
      onError: (e) {
        setState(() {
          _error();
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


  int _solde() {
    int sl = 0;
    if (test.isNotEmpty) {
      sl = test[0]['solde'];
    }
    return sl;
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
    return TextButton(
        onPressed: (){
          getmoisCom();
        },
        child: Text(NumberFormat("#,###,###,### CFA").format(_ca()), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),));
  }

  _getSolde()
  {
    if(!gotSolde)
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
    if(gotSoldeError)
      {
        return Center(
          child: Column(
            children: [
              TextButton(
                child: const Text("Réessayer", style: TextStyle(color: Colors.green),), onPressed: () {
                setState(() {
                  soldeList.clear();
                  getSolde();
                });
              },),
            ],
          ),
        );
      }
    return Text(NumberFormat("#,###,###,### CFA").format(_solde()), style: const TextStyle(fontWeight: FontWeight.bold),);
  }

  void sharePoint()
  async{
    await Share.share(
        "Numéro: ${widget.pdv.numeroFlooz ?? 'Non renseigné'}\n\n"
            "Nom: ${widget.pdv.nomDuPoint ?? 'Non renseigné'}\n\n"
            "Numéro propriétaire: ${widget.pdv.numeroProprietaireDuPdv ?? 'Non renseigné'}\n\n"
            "Quartier: ${widget.pdv.quartier ?? 'Non renseigné'}\n\n"
            "Localisation: ${widget.pdv.localisation ?? 'Non renseigné'}\n\n"
            "Commercial: ${widget.pdv.commercial ?? 'Non renseigné'}\n\n",
      subject: "Informations du point"
    );
  }

  Widget _callPdv(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(),
        icon: Icon(Icons.call, color: philMainColor),
        onPressed: () async {
          List<String> numero = phoneNumber.split('/');
          _chooseNumber(numero);
        },
        label: const Text("Composer le numéro propriétaire"),
      );
    }
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(),
      icon: Icon(Icons.call, color: philMainColor),
      onPressed: () async {
      },
      label: const Text("Numero non renseigné"),
    );
  }


  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Couleur de fond du SnackBar
      ),
    );
  }

  Future<void> _chooseNumber(List<String> numbers) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sélectioneer le numéro à composer"),
          content:  Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: numbers.length,
                itemBuilder: (context, index)
                {
                  return ElevatedButton(
                    onPressed: () async{
                      final Uri phoneLaunchUri = Uri(
                        scheme: 'tel',
                        path: numbers[index],
                      );
                      if (await canLaunchUrl(phoneLaunchUri)) {
                      showErrorMessage(context, "Une erreur est survenues, veuillez réessayer");
                      } else {
                      await launchUrl(phoneLaunchUri);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(numbers[index]),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _seeCommMonth() async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool poped) {
            if (!poped) {
              setState(() {
                commMonth.clear();
              });
            }
          },
          child: AlertDialog(
            title: Text(
              "Les commissions de ${widget.pdv.nomDuPoint}",
              style: const TextStyle(fontSize: 17),
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: commMonth.length,
                  itemBuilder: (context, index) {
                    return commByMonth(commMonth[index]);
                  },
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    commMonth.clear();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _nothing() async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool poped) {
            if (!poped) {
              setState(() {
                commMonth.clear();
              });
            }
          },
          child: AlertDialog(
            title: Text(
              "Les commissions de ${widget.pdv.nomDuPoint}",
              style: const TextStyle(fontSize: 17),
            ),
            content: const Text("Aucune commission pour l'année en cours"),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    commMonth.clear();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _error() async {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool poped) {
            if (!poped) {
              setState(() {
                commMonth.clear();
              });
            }
          },
          child: AlertDialog(
            title: Text(
              "Les commissions de ${widget.pdv.nomDuPoint}",
              style: const TextStyle(fontSize: 17),
            ),
            content: const Text("Erreur, veuillez réessayer"),
            actions: <Widget>[
              TextButton(
                child: const Text('Réessayer'),
                onPressed: () {
                  Navigator.of(context).pop();
                  getmoisCom();
                },
              ),
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

            ],
          ),
        );
      },
    );
  }


  Widget commByMonth(ChiffreAffaire cbm)
  {
            return Text(
                "${_getMonthName(int.parse(cbm.date?? '-'))} : ${NumberFormat("#,###,###,### CFA").format(cbm.chiffreAffaire)}",
                    style: const TextStyle(fontSize: 15),
            );
  }

  String _getMonthName(int monthNumber) {
    const monthNames = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];
    return monthNames[monthNumber - 1];
  }


}
