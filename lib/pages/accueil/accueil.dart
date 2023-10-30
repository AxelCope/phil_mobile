import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/caPdv.dart';
import 'package:phil_mobile/models/pdvs.dart';
import 'package:phil_mobile/pages/accueil/details_point.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/performances/dotations_reconversion.dart';
import 'package:phil_mobile/pages/sim%20services/swap%20grille.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:intl/intl.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.comm});

  final Comms comm ;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchFieldController = TextEditingController();
  List<PointDeVente> listPdvs = [];
  List<ChiffreAffaire> objectifComm = [];
  List<ChiffreAffaire> commCagnt = [];
  List<PointDeVente>? _searchList;
  late final QueriesProvider _provider;
  DateTime date = DateTime.now();
  bool gotObjectif = false;
  bool gotComm = false;



  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
    fetchPdvs();
    objectifsComm();
    getCommission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
             DrawerHeader(
               padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: philMainColor,
              ),
              child: Column(
                children: [
                  Text(widget.comm.nomCommerciaux!, style: TextStyle(fontSize: 25),),
                  Text(widget.comm.id!.toString(), style: TextStyle(fontSize: 20),),
                  SizedBox(height: 10,),
                  Text(" Commission zone/Objectif du mois", style: TextStyle(fontWeight: FontWeight.bold),),
                  _getCa(),
                ],
              ),
            ),

            ListTile(
              title: Text("Mes dotations et reconversions"),
              leading: Icon(Icons.swap_horiz),
              onTap: (){
                nextPage(context, Performances(comms: widget.comm));
              },
            ),
            ListTile(
              title: Text("Mes inactifs"),
              leading: Image.asset('assets/inactifs.png', width: 30,),
            ),
            ListTile(
              title: Text("Mes segments"),
              leading: Image.asset('assets/store.png', width: 30,),
            ),

            ExpansionTile(title: Text("Services SIM"),
            children: [
              ListTile(
                leading: Image.asset('assets/creation.png'),
                title: const Text('Créer un nouveau pdv'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              SizedBox(height: 20,),
              ListTile(
                leading: Image.asset('assets/sim swap.png'),
                title: const Text('Swapp pour redéploiement'),
                onTap: () {
                },
              ),
              SizedBox(height: 20,),
              ListTile(
                leading: Image.asset('assets/sim broken.png'),
                title: const Text('Swapp pour SIM grillé ou perdu'),
                onTap: () {
                  nextPage(context, SwappGrille(pdvs: listPdvs,));
                },
              ),
              SizedBox(height: 20,),
              ListTile(
                leading: Image.asset('assets/update.png'),
                title: const Text('Update pdv'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),

            ],),

          ],
        ),
      ),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(" Mon univers (${listPdvs.length} pdvs)"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
          TextField(
            onChanged: _search,
          controller: _searchFieldController,
          cursorColor:  philMainColor,
          style: GoogleFonts.dmSans(color: Colors.black.withOpacity(0.6)),
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, size: 25, color:  hexToColor('#AAA6B9'),),
              hintText: "Rechercher un point de vente",
              hintStyle: GoogleFonts.dmSans(color: Colors.black, fontSize: 13),
              filled: true,
              suffixIcon: _searchFieldController.text.isNotEmpty ? IconButton(
                onPressed: (){
                  setState(() {
                    _searchFieldController.text = '';
                    _searchList = null;
                  });
                },
                icon: Icon(Icons.close),
              ) : null,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.transparent,)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.transparent,)
              ),
              fillColor: hexToColor('#f5f5f5'),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30)
              )
          ),
        ),
            Expanded(child: _buildPdvs())
          ]
    ),
      )
    );
  }

  _pdvs(PointDeVente pdvs)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: hexToColor('#f5f5f5'),
        ),
        child: GestureDetector(
          onTap: (){
           nextPage(context, PageDetailsPdv(pdv: pdvs));
          },
          child: ListTile(
            title: Text("${pdvs.nomDuPoint} "),
            subtitle: Text("${pdvs.numeroFlooz}"),
          ),
        ),
      ),
    );
  }
  _buildPdvs()
  {
    if(_searchList != null) {
      if(_searchList!.isNotEmpty) {
        return
          ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _searchList!.length,
              itemBuilder: (BuildContext context, int i) {
                return _pdvs(_searchList![i]);
              });
      }
      return const Padding(
        padding:   EdgeInsets.only(top:100.0),
        child:   Center(
          child: Text('Aucun resultat'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: listPdvs.length,
        itemBuilder: (BuildContext, index)
    {
      return _pdvs(listPdvs[index]);
    });
  }

  Future<void> fetchPdvs() async {
    await _provider.fetchPdvs(
      secure: false,
      id: widget.comm.id,
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            listPdvs.add(PointDeVente.MapPdvs(element));
          }
        });
      },
      onError: (e) {
        setState(() {
          print(e);
        });
      },
    );
  }

  Future<void> objectifsComm() async {
    await _provider.objectifsbyComm(
      secure: false,
      id: widget.comm.id,
      date: 'OCTOBER',
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
    await _provider.commissionCommerciaux(
      secure: false,
      cmId: widget.comm.id,
      date: date.month,
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            print(element);
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


  void _search(String value) {
    if(value.trim().isNotEmpty) {
      _searchList = [];
      _searchList!.addAll(listPdvs.where((element) =>
      (element.nomDuPoint != null && element.nomDuPoint!.toLowerCase().contains(value))
          || element.nomDuPoint!.toLowerCase().contains(value.toLowerCase()) || element.numeroFlooz!.toString().contains(value))
      );
      setState(() {
      });
    } else {
      setState(() {
        _searchList = null;
      });
    }
  }


  _getCa()
  {

    int obj = 0;
    int comm = 0;
    if(!gotObjectif && !gotComm)
    {
      return SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }
    if(objectifComm.isNotEmpty && commCagnt.isNotEmpty)
    {
      obj = objectifComm[0].obj!;
      comm = commCagnt[0].comm!;
    }
    return Column(
      children: [
        Text(" ${NumberFormat("###,### CFA").format(comm)} /${NumberFormat("###,### CFA").format(obj)}  ", style: TextStyle(fontWeight: FontWeight.bold),),
        SizedBox(height:5,),
        LinearProgressIndicator(
          value: ((comm/(obj))*100)/100,
          backgroundColor: hexToColor("#87CEEB"), // Couleur de la barre
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6cc167)),
        )
      ],
    );
  }

}
