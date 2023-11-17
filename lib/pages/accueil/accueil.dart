import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/caPdv.dart';
import 'package:phil_mobile/models/pdvs.dart';
import 'package:phil_mobile/pages/accueil/details_point.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/performances/inactifs.dart';
import 'package:phil_mobile/pages/performances/tabs.dart';
import 'package:phil_mobile/pages/performances/page_givecom.dart';
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
  bool gotPdvs = true;
  bool gotPdvsError = false;



  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
    fetchPdvs();
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
                  Text(widget.comm.nicknameCommerciaux!, style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
            ),

            ListTile(
              title: Text("Mes performances"),
              leading: Icon(Icons.swap_horiz),
              onTap: (){
                nextPage(context, Performances(comms: widget.comm));
              },
            ),
            ListTile(
              title: Text("Mes inactifs"),
              onTap: (){
                nextPage(context, PageInactifs(comms: widget.comm));
              },
              leading: Image.asset('assets/inactifs.png', width: 30,),
            ),
            ListTile(
              title: Text("Points qui vont en banque"),
              leading: SvgPicture.asset('assets/givecom.svg', width: 30,),
              onTap: (){
                nextPage(context, PageGiveComs(comms: widget.comm));
              },
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
            subtitle: Text("${pdvs.numeroFlooz}\nNombre de dotations dans le mois: ${pdvs.dotee ?? "0"} "),
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

    if(gotPdvs)
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
    if(gotPdvsError){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Nous n'avons pas pu contacter le serveur"),
          TextButton(
            child: Text("Veuillez réessayer", style: TextStyle(color: Colors.green),), onPressed: () {
            setState(() {
              listPdvs.clear();
              fetchPdvs();
            });
          },),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listPdvs.length,
          itemBuilder: (BuildContext, index)
      {
        return _pdvs(listPdvs[index]);
      }),
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
      month: date.month - 1,
      onSuccess: (r) {
        setState(() {
          for(var element in r)
          {
            listPdvs.add(PointDeVente.MapPdvs(element));
          }
          gotPdvs = false;
          gotPdvsError = false;

        });
      },
      onError: (e) {
        setState(() {
          gotPdvs = false;
          gotPdvsError = true;
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

  Future<void> _refresh() async {
    setState(() {
      listPdvs.clear();
      fetchPdvs();
    });
  }


}
