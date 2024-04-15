import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/model_chiffre_daffaire.dart';
import 'package:phil_mobile/models/model_point_de_ventes.dart';
import 'package:phil_mobile/pages/accueil/page_detail_pdvs.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/queries_provider.dart';


class UniversAdmin extends StatefulWidget {
  const UniversAdmin({super.key});

  @override
  State<UniversAdmin> createState() => _UniversAdminState();
}

class _UniversAdminState extends State<UniversAdmin> with AutomaticKeepAliveClientMixin{
  bool _isMounted = false;
  final TextEditingController _searchFieldController = TextEditingController();
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
    _isMounted = true;
    _initProvider();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
    fetchPdvs();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                          icon: const Icon(Icons.close),
                        ) : null,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.transparent,)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.transparent,)
                        ),
                        fillColor: hexToColor('#f5f5f5'),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
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
    var colorsStyle = Colors.black;
    var decoration = TextDecoration.none;
    var status = hexToColor('#f5f5f5');
    if(pdvs.status == false)
    {
      decoration = TextDecoration.lineThrough;
    }
    if(pdvs.dotee == 0)
    {
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
          onTap: (){
            nextPage(context, PageDetailsPdv(pdv: pdvs));
          },
          child: ListTile(
            title: Text("${pdvs.nomDuPoint}", style: TextStyle(decoration: decoration, fontWeight: FontWeight.bold),),
            subtitle: Text("${pdvs.numeroFlooz}\nNombre de dotations dans le mois: ${pdvs.dotee}",
              style: TextStyle(color: colorsStyle),),
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
          const Text("Nous n'avons pas pu contacter le serveur"),
          TextButton(
            child: const Text("Veuillez réessayer", style: TextStyle(color: Colors.green),), onPressed: () {
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
          itemBuilder: (context, index)
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
        if(_isMounted) {
          setState(() {
            print(e);
            gotPdvs = false;
            gotPdvsError = true;
          });
        }
      },
    );
  }


  void _search(String value) {
    if(value.trim().isNotEmpty) {
      setState(() {
        _searchList = listPdvs.where((element) =>
        (element.nomDuPoint != null && element.nomDuPoint!.toLowerCase().contains(value))
            || (element.nomDuPoint != null && element.nomDuPoint!.toLowerCase().contains(value.toLowerCase()))
            || (element.numeroFlooz != null && element.numeroFlooz!.toString().contains(value)))
            .toList();
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
  @override
  bool get wantKeepAlive => true;

}
