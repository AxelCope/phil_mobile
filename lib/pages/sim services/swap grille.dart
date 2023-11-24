import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/pdvs.dart';
import 'package:phil_mobile/pages/consts.dart';

class SwappGrille extends StatefulWidget {
  const SwappGrille({super.key, required this.pdvs});

  final List<PointDeVente> pdvs;

  @override
  State<SwappGrille> createState() => _SwappGrilleState();
}

class _SwappGrilleState extends State<SwappGrille> {
  final TextEditingController _searchFieldController = TextEditingController();
   List<PointDeVente>? _searchList;
  List<PointDeVente> swapPending = [];
  final List<PointDeVente> _checkedList = [];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: _checkedList.isNotEmpty ? Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          style:  ElevatedButton.styleFrom(backgroundColor: philMainColor, padding: const EdgeInsets.symmetric(horizontal: 100)),
          child: const Text("Envoyer le swapp", style: TextStyle(color: Colors.white),),
          onPressed: (){
          _confirmationSheet(context);
          },
        ),
      ): null,
      backgroundColor: Colors.grey.shade200,
      body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 21.0, right: 21, top: 45, bottom: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))
              ),
              child:  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Signaler le dysfonctionnement ou la perte/vol d'une carte SIM", textAlign: TextAlign.center,style: TextStyle(fontSize: 20),),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                    child: TextField(
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
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: philMainColor,)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: philMainColor, width: 3,)
                          ),
                          fillColor: hexToColor('#FFFFFF'),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(child: _buildPdvs())
          ]
      ),
    );
  }
  _pdvs(PointDeVente pdvs)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: hexToColor('#FFFFFF'),
        ),
        child: CheckboxListTile(
          onChanged: (changed){
            setState(() {
                 if(changed!)
                  {
                    pdvs.checked = changed;
                    _checkedList.add(pdvs);
                }
                else{

                   pdvs.checked = changed;
                   _checkedList.remove(pdvs);
                }

            });
          },
          value: pdvs.checked,
          title: Text("${pdvs.nomDuPoint} "),
          subtitle: Text("${pdvs.numeroFlooz}"),
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
        itemCount: widget.pdvs.length,
        itemBuilder: (BuildContext, index)
        {
          return _pdvs(widget.pdvs[index]);
        });
  }

  void _search(String value) {
    if(value.trim().isNotEmpty) {
      _searchList = [];
      _searchList!.addAll(widget.pdvs.where((element) =>
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

  _confirmationSheet(context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _checkedList.length,
                itemBuilder: (BuildContext context, index) {
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(_checkedList[index].nomDuPoint!),
                          subtitle: Text(_checkedList[index].numeroFlooz!.toString()),
                          trailing: IconButton(
                            icon: const Icon(Icons.message),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String? holder = _checkedList[index].comment.text;
                                  TextEditingController commentController =
                                  TextEditingController(text: holder);
                                  return AlertDialog(
                                    title: const Text('Ajouter un Commentaire'),
                                    content: TextField(
                                      controller: commentController,
                                      decoration: const InputDecoration(hintText: "Commentaires"),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Annuler'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Valider'),
                                        onPressed: () {
                                          setState(() {
                                            holder = commentController.text;
                                            _checkedList[index].comment =
                                                TextEditingController(text: holder);
                                            Navigator.of(context).pop();
                                            print(holder);
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  backgroundColor: philMainColor,
                  onPressed: () {
                    // Add functionality for the FloatingActionButton
                  },
                  child: const Text("ENVOYER", style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _settingModalBottomSheet(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.music_note),
                    title: const Text('Music'),
                    onTap: () => {}
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Video'),
                  onTap: () => {},
                ),
              ],
            ),
          );
        }
    );
  }

}
