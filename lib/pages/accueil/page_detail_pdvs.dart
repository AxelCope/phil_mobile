import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/model_chiffre_daffaire.dart';
import 'package:phil_mobile/models/model_point_de_ventes.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/pages/services/transactions/pdv_page_transactions.dart';
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
  TextEditingController imsi = TextEditingController();
  List<ChiffreAffaire> listCA = [];
  List<ChiffreAffaire> listDealerCA = [];
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
    getDalerCA();
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
                shareInformations();
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
                Text(widget.pdv.nomDuPoint!, style: const TextStyle(fontSize: 25), textAlign: TextAlign.center,),
                const SizedBox(height: 10,),
                Text(widget.pdv.numeroFlooz!.toString(), style: const TextStyle(fontSize: 21),),
                const SizedBox(height: 10,),
                OutlinedButton(onPressed: (){
                  nextPage(context, PagePdvTransactions(pdv: widget.pdv));
                }, child: const Text("Voir les transactions"))
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
                    _getDealerCa(),
                    const SizedBox(width: 8,),

                    Text("(Commissions Dealer)" , style: TextStyle( fontSize: 12 ))
                  ],
                ),

                const SizedBox(height: 12,),


                Row(
                  children: [
                    _getCa(),
                    const SizedBox(width: 8,),

                    Text("(Commissions PDV)" , style: TextStyle( fontSize: 12 ))
                  ],
                ),

                const SizedBox(height: 15,),
                Row(
                  children: [
                    Image.asset("assets/page infos pdvs/wallet.png", width: 30),
                    const SizedBox(width: 16,),
                    _getSolde(),
                    const SizedBox(width: 8,),
                    Text("(Solde à 5h00)", style: TextStyle( fontSize: 12 ))
                  ],
                ),
                const SizedBox(height: 30,),
                Text("Profile: ${widget.pdv.profil ?? '(Non renseigné)'}", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 25,),
                Text("Numero du propirétaire: ${widget.pdv.numeroProprietaireDuPdv ?? '(Non renseigné)'} ( ${widget.pdv.sexeDuGerant ?? '(Non renseigné)'})", style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 25,),
                _callPdv(widget.pdv.numeroProprietaireDuPdv),
                const SizedBox(height: 25,),
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
                            double dl = widget.pdv.longitude!;
                            double dL = widget.pdv.latitude!;
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
      pdv: widget.pdv.numeroFlooz.toString(),
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
          print(e);
          gotCaError = true;
          gotCa = true;
        });
      },
    );
  }

  Future<void>  getDalerCA() async {
    setState(() {
      gotCaError = false;
      gotCa = false;
    });
    await _provider.getDealerCA(
      secure: false,
      pdv: widget.pdv.numeroFlooz,
      month: date.month,
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            listDealerCA.add(ChiffreAffaire.MapChiffresaffaire(element));
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
          print(e);
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

  _dealerCa()
  {
    double ca = 0;
    if(listDealerCA.isNotEmpty)
    {
      ca = listDealerCA[0].chiffreAffaire!;
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
    return Row(
      children: [
        Image.asset("assets/page infos pdvs/income.png", width: 30, color: philMainColor,),
        const SizedBox(width: 3,),
        TextButton(
            onPressed: (){
              getmoisCom();
            },
            child: Text(NumberFormat("#,###,###,### CFA").format(_ca()), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),)),
      ],
    );
  }

  _getDealerCa()
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
                listDealerCA.clear();
                getCA();
              });
            },),
          ],
        ),
      );
    }
    return Row(
      children: [
        Icon(Icons.home_work_outlined),
        const SizedBox(width: 10,),
        TextButton(
            onPressed: (){
              getmoisCom();
            },
            child: Text(NumberFormat("#,###,###,### CFA").format(_dealerCa()), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),)),
      ],
    );
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

  void shareInformations()
  async{
    showOptionsDialog(context);
  }

  void sharePointInformations()
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

  void shareFreecall(String imsi)
  async{
    await Share.share(
            "Motif: *FREECALL + NOTIFICATIONS* \n\n"
            "Numéro: ${widget.pdv.numeroFlooz ?? 'Non renseigné'}\n\n"
                "IMSI: $imsi\n\n"
                "Numéro privé: ${widget.pdv.numeroProprietaireDuPdv ?? 'Non renseigné'}\n\n"
                "Nom: ${widget.pdv.nomDuPoint ?? 'Non renseigné'}\n\n"
            "Commercial: ${widget.pdv.commercial ?? 'Non renseigné'}\n\n"

        ,
        subject: "Free Call"
    );
  }
  void shareSwappGrille(String imsi)
  async{
    await Share.share(
        "Motif: *SIM GRILLÉE* \n\n"
        "Numéro: ${widget.pdv.numeroFlooz ?? 'Non renseigné'}\n\n"
            "Nom: ${widget.pdv.nomDuPoint ?? 'Non renseigné'}\n\n"
            "Numéro privé: ${widget.pdv.numeroProprietaireDuPdv ?? 'Non renseigné'}\n\n"
            "Nouvelle imsi: $imsi\n\n"
            "Région: ${widget.pdv.region}\n\n"
            "Ville: ${widget.pdv.canton}\n\n"
            "Quartier: ${widget.pdv.quartier ?? 'Non renseigné'}\n\n"
            "Latitude: ${widget.pdv.latitude}\n\n"
            "Longitude: ${widget.pdv.longitude}\n\n"
            "Localisation: ${widget.pdv.localisation ?? 'Non renseigné'}\n\n"
            "Commercial: ${widget.pdv.commercial ?? 'Non renseigné'}\n\n"
            // "Date de demande: ${date.day}/${date.month}/${date.hour}, ${date.hour}:${date.minute}\n\n"
        ,
        subject: "SIM GRILLÉE"
    );
  }
void shareSwappEgare(String imsi)
  async{
    await Share.share(
        "Motif: *SIM ÉGARÉE* \n\n"
            "Numéro: ${widget.pdv.numeroFlooz ?? 'Non renseigné'}\n\n"
            "Nom: ${widget.pdv.nomDuPoint ?? 'Non renseigné'}\n\n"
            "Numéro privé: ${widget.pdv.numeroProprietaireDuPdv ?? 'Non renseigné'}\n\n"
            "Nouvelle imsi: $imsi\n\n"
            "Région: ${widget.pdv.region}\n\n"
            "Ville: ${widget.pdv.canton}\n\n"
            "Quartier: ${widget.pdv.quartier ?? 'Non renseigné'}\n\n"
            "Latitude: ${widget.pdv.latitude}\n\n"
            "Longitude: ${widget.pdv.longitude}\n\n"
            "Localisation: ${widget.pdv.localisation ?? 'Non renseigné'}\n\n"
            "Commercial: ${widget.pdv.commercial ?? 'Non renseigné'}\n\n"
            // "Date de demande: ${date.day}/${date.month}/${date.hour}, ${date.hour}:${date.minute}\n\n"
        ,
        subject: "SIM ÉGARÉE"
    );
  }
void shareReversemnt(String rv)
  async{
    await Share.share(
        "Motif: *Problèmes de reversement* \n\n"
            "Numéro: ${widget.pdv.numeroFlooz ?? 'Non renseigné'}\n\n"
            "Nom: ${widget.pdv.nomDuPoint ?? 'Non renseigné'}\n\n"
            "Numéro privé: ${widget.pdv.numeroProprietaireDuPdv ?? 'Non renseigné'}\n\n"
            "Nouveau numero de reversement: $rv\n\n"
            "Commercial: ${widget.pdv.commercial ?? 'Non renseigné'}\n\n"
            // "Date de demande: ${date.day}/${date.month}/${date.hour}, ${date.hour}:${date.minute}\n\n"
        ,
        subject: "Reversement"
    );
  }
void shareReinitialisation(String rv, String motif)
  async{
    await Share.share(
        "Motif: *REINITIALISATION* \n\n"
            "Numéro: ${widget.pdv.numeroFlooz ?? 'Non renseigné'}\n\n"
            "Nom: ${widget.pdv.nomDuPoint ?? 'Non renseigné'}\n\n"
            "Numéro privé: ${widget.pdv.numeroProprietaireDuPdv ?? 'Non renseigné'}\n\n"
            "Nouvelle imsi: $rv\n\n"
            "Motif réinitialisation: $motif\n\n"
            "Commercial: ${widget.pdv.commercial ?? 'Non renseigné'}\n\n"
            // "Date de demande: ${date.day}/${date.month}/${date.hour}, ${date.hour}:${date.minute}\n\n"
        ,
        subject: "Reversement"
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


  void showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  sharePointInformations();
                },
                child: const Center(
                  child: Text(
                    "Envoyer les informations du point",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black,),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialogReinitialisation(context, "Réinitialisation");
                },
                child: const Center(
                  child: Text(
                    "Réinitialisation",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showIMSIDialogFreecall(context, "Demande de FreeCall");
                },
                child: const Center(
                  child: Text(
                    "Demande de FreeCall",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showSwappDialog(context);
                },
                child: const Center(
                  child: Text(
                    "Swapps",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialogReversement(context, "Reversement");
                },
                child: const Center(
                  child: Text(
                    "Problème de reversement",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void showSwappDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Demande de Swapp"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Appeler showIMSIDialogGrille avec le titre "Sim grillé"
                  showIMSIDialogGrille(context, "Sim grillée");
                },
                child: const Center(
                  child: Text(
                    "Sim grillée",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Appeler showIMSIDialogEgare avec le titre "Sim égaré"
                  showIMSIDialogEgare(context, "Sim égarée");
                },
                child: const Center(
                  child: Text(
                    "Sim égarée",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showIMSIDialogFreecall(BuildContext context, String title) {
    final TextEditingController imsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: imsiController,
            maxLength: 21, // Limite à 12 caractères
            decoration: const InputDecoration(
              labelText: "Entrez le code IMSI",
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareFreecall(imsiController.text);
                print("Code IMSI saisi: ${imsiController.text}");
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }
  void showIMSIDialogGrille(BuildContext context, String title) {
    final TextEditingController imsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: imsiController,
            maxLength: 21, // Limite à 12 caractères
            decoration: const InputDecoration(
              labelText: "Entrez le code IMSI",
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareSwappGrille(imsiController.text);
                print("Code IMSI saisi: ${imsiController.text}");
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }
  void showIMSIDialogEgare(BuildContext context, String title) {
    final TextEditingController imsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: imsiController,
            maxLength: 21, // Limite à 12 caractères
            decoration: const InputDecoration(
              labelText: "Entrez le code IMSI",
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareSwappEgare(imsiController.text);
                print("Code IMSI saisi: ${imsiController.text}");
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }
  void showDialogReversement(BuildContext context, String title) {
    final TextEditingController numeroReversement = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: numeroReversement,
            maxLength: 21, // Limite à 12 caractères
            decoration: const InputDecoration(
              labelText: "Entrez le numéro de reversement",
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareReversemnt(numeroReversement.text);
              },
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }
  void showDialogReinitialisation(BuildContext context, String title) {
    final TextEditingController imsiR = TextEditingController();
    final TextEditingController motif = TextEditingController();

    // Variable to track button state
    bool isButtonEnabled = false;

    void updateButtonState() {
      isButtonEnabled = imsiR.text.isNotEmpty && motif.text.isNotEmpty;
    }

    // Initial check for button state
    updateButtonState();

    // Listen for changes in the text fields
    imsiR.addListener(updateButtonState);
    motif.addListener(updateButtonState);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: imsiR,
                    maxLength: 21,
                    decoration: const InputDecoration(
                      labelText: "Entrez l'imsi",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {
                        updateButtonState();
                      });
                    },
                  ),
                  TextField(
                    controller: motif,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Renseignez le motif",
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (_) {
                      setState(() {
                        updateButtonState();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isButtonEnabled
                      ? () {
                    Navigator.of(context).pop();
                    shareReinitialisation(imsiR.text, motif.text);
                  }
                      : null, // Disable button if fields are empty
                  child: const Text("Valider"),
                ),
              ],
            );
          },
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