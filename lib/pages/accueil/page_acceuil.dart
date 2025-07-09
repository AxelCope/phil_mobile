import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/model_chiffre_daffaire.dart';
import 'package:phil_mobile/models/model_point_de_ventes.dart';
import 'package:phil_mobile/pages/accueil/page_detail_pdvs.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/login/page_connexion.dart';
import 'package:phil_mobile/pages/services/inactifs/page_inactifs.dart';
import 'package:phil_mobile/pages/services/givecom/page_givecom.dart';
import 'package:phil_mobile/pages/accueil/settings.dart';
import 'package:phil_mobile/pages/services/ranking_comms/ranking.dart';
import 'package:phil_mobile/pages/tabs/tabs.dart';
import 'package:phil_mobile/pages/services/transactions/comm_page_transactions.dart';
import 'package:phil_mobile/provider/queries_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.comm});

  final Comms comm;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchFieldController = TextEditingController();
  List<PointDeVente> listPdvs = [];
  List<ChiffreAffaire> objectifComm = [];
  List<ChiffreAffaire> commCagnt = [];
  List<PointDeVente>? _searchList;
  late final QueriesProvider _provider;
  DateTime date = DateTime.now();
  bool gotPdvs = true;
  bool gotPdvsError = false;
  String? _sortBy; // 'solde' ou 'dotee'
  bool _isAscending = false; // false: DESC, true: ASC

  @override
  void initState() {
    super.initState();
    _initProvider();
    // Ajouter le tag OneSignal pour le commercial
    OneSignal.User.addTags({"comm_id": widget.comm.id.toString()});
  }

  void _initProvider() async {
    _provider = await QueriesProvider.instance;
    fetchPdvs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: philMainColor,
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.comm.nomCommerciaux!,
                          style: const TextStyle(fontSize: 25),
                        ),
                        Text(
                          widget.comm.id!.toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.comm.nicknameCommerciaux!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text("Mes performances"),
                    leading: const Icon(Icons.swap_horiz),
                    onTap: () {
                      nextPage(context, Tabs(comms: widget.comm));
                    },
                  ),
                  ListTile(
                    title: const Text("Mes inactifs"),
                    onTap: () {
                      nextPage(context, PageInactifs(comms: widget.comm));
                    },
                    leading: Image.asset(
                      'assets/page des inactifs/inactifs.png',
                      width: 30,
                    ),
                  ),
                  ListTile(
                    title: const Text("Points qui vont en banque"),
                    leading: SvgPicture.asset(
                      'assets/page givecom/givecom.svg',
                      width: 30,
                    ),
                    onTap: () {
                      nextPage(context, PageGiveComs(comms: widget.comm));
                    },
                  ),
                  ListTile(
                    title: const Text("Mes transactions"),
                    leading: SvgPicture.asset(
                      'assets/services/transactions.svg',
                      width: 35,
                    ),
                    onTap: () {
                      nextPage(context, PageTransactions(comms: widget.comm));
                    },
                  ),
                  ListTile(
                    title: const Text("Classement"),
                    leading: SvgPicture.asset(
                      'assets/services/rank.svg',
                      width: 35,
                    ),
                    onTap: () {
                      nextPage(context, RankingPage(widget.comm));
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text(
                  'Paramètres',
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  nextPage(context, PageSettings(comm: widget.comm));
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'Se déconnecter',
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () => _setPreferences(context),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        scrolledUnderElevation: 2.0,
        elevation: 0,
        centerTitle: true,
        title: Text(" Mon univers (${listPdvs.length} pdvs)"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              onChanged: _search,
              controller: _searchFieldController,
              cursorColor: philMainColor,
              style: TextStyle(color: Colors.black.withValues(red: 0.6)),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: 25,
                  color: hexToColor('#AAA6B9'),
                ),
                hintText: "Rechercher un point de vente",
                hintStyle: const TextStyle(color: Colors.black, fontSize: 13),
                filled: true,
                suffixIcon: _searchFieldController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchFieldController.text = '';
                      _searchList = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                fillColor: hexToColor('#f5f5f5'),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_sortBy == 'solde') {
                        _isAscending = !_isAscending;
                      } else {
                        _sortBy = 'solde';
                        _isAscending = false;
                      }
                      _sortList();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _sortBy == 'solde'
                          ? philMainColor
                          : hexToColor('#f5f5f5'),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Trie solde",
                          style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).size.width * 0.025,
                            color:
                            _sortBy == 'solde' ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          _sortBy == 'solde'
                              ? (_isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                              : Icons.sort,
                          size: 18,
                          color:
                          _sortBy == 'solde' ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_sortBy == 'dotee') {
                        _isAscending = !_isAscending;
                      } else {
                        _sortBy = 'dotee';
                        _isAscending = false;
                      }
                      _sortList();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _sortBy == 'dotee'
                          ? philMainColor
                          : hexToColor('#f5f5f5'),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Trie dotations",
                          style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).size.width * 0.025,
                            color:
                            _sortBy == 'dotee' ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          _sortBy == 'dotee'
                              ? (_isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                              : Icons.sort,
                          size: 18,
                          color:
                          _sortBy == 'dotee' ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: _buildPdvs()),
          ],
        ),
      ),
    );
  }

  _pdvs(PointDeVente pdvs) {
    var colorsStyle = Colors.black;
    var decoration = TextDecoration.none;
    var status = hexToColor('#f5f5f5');
    if (pdvs.status == false) {
      decoration = TextDecoration.lineThrough;
    }
    if (pdvs.dotee == 0) {
      colorsStyle = Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: status,
        ),
        child: GestureDetector(
          onTap: () {
            nextPage(context, PageDetailsPdv(pdv: pdvs));
          },
          child: ListTile(
            title: Text(
              "${pdvs.nomDuPoint}",
              style: TextStyle(
                  decoration: decoration, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${pdvs.numeroFlooz}\nDotations dans le mois: ${pdvs.dotee}\nSolde: ${pdvs.solde}",
              style: TextStyle(color: colorsStyle),
            ),
          ),
        ),
      ),
    );
  }

  _buildPdvs() {
    if (_searchList != null) {
      if (_searchList!.isNotEmpty) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: _searchList!.length,
          itemBuilder: (BuildContext context, int i) {
            return _pdvs(_searchList![i]);
          },
        );
      }
      return const Padding(
        padding: EdgeInsets.only(top: 100.0),
        child: Center(
          child: Text('Aucun resultat'),
        ),
      );
    }

    if (gotPdvs) {
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
    if (gotPdvsError) {
      return Column(
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
                listPdvs.clear();
                fetchPdvs();
              });
            },
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listPdvs.length,
        itemBuilder: (context, index) {
          return _pdvs(listPdvs[index]);
        },
      ),
    );
  }

  Future<void> fetchPdvs() async {
    setState(() {
      gotPdvs = true;
      gotPdvsError = false;
    });
    await _provider.fetchPdvs(
      secure: false,
      id: widget.comm.id,
      month: date.month,
      onSuccess: (r) {
        setState(() {
          for (var element in r) {
            listPdvs.add(PointDeVente.MapPdvs(element));
          }
          gotPdvs = false;
          gotPdvsError = false;
        });
      },
      onError: (e) {
        setState(() {
          print(e);
          gotPdvs = false;
          gotPdvsError = true;
        });
      },
    );
  }

  void _sortList() {
    List<PointDeVente> listToSort = _searchList ?? listPdvs;
    if (_sortBy == 'solde') {
      listToSort.sort((a, b) {
        return _isAscending
            ? a.solde!.compareTo(b.solde!)
            : b.solde!.compareTo(a.solde!);
      });
    } else if (_sortBy == 'dotee') {
      listToSort.sort((a, b) {
        return _isAscending
            ? a.dotee!.compareTo(b.dotee!)
            : b.dotee!.compareTo(a.dotee!);
      });
    }
    setState(() {
      if (_searchList != null) {
        _searchList = List.from(listToSort);
      } else {
        listPdvs = List.from(listToSort);
      }
    });
  }

  void _search(String value) {
    if (value.trim().isNotEmpty) {
      _searchList = [];
      _searchList!.addAll(listPdvs.where((element) =>
      (element.nomDuPoint != null &&
          element.nomDuPoint!.toLowerCase().contains(value)) ||
          element.nomDuPoint!.toLowerCase().contains(value.toLowerCase()) ||
          element.numeroFlooz!.toString().contains(value)));
      setState(() {});
    } else {
      setState(() {
        _searchList = null;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      listPdvs.clear();
      fetchPdvs();
    });
    }

        Future<void> _setPreferences(BuildContext context) async {
      try {
        bool confirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Déconnexion'),
              content: const Text('Voulez vous vraiment vous déconneter ?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel the logout
                  },
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirm the logout
                  },
                  child: const Text('Se déconnecter'),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          _loginOutDialog();
          await Future.delayed(const Duration(seconds: 2));
          Navigator.of(context).pop();
          final box = await Hive.openBox('commsBox');
          await box.clear();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const LoginPage()));
        }
      } catch (e) {}
    }

    _loginOutDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          );
        },
      );
    }
  }