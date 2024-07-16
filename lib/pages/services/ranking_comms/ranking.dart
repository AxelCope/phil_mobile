import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phil_mobile/models/model_chiffre_daffaire.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:phil_mobile/methods/methods.dart';

class RankingPage extends StatefulWidget {
  final Comms comms;

  RankingPage(this.comms);

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final List<ChiffreAffaire> commercials = [];
  bool isLoading = true;
  late final QueriesProvider _provider;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    _provider = await QueriesProvider.instance;
    fetchRank();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement des Commerciaux'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading ? _buildLoadingIndicator() : rankList(),
      ),
    );
  }

  Widget rankList() {
    return ListView.builder(
      itemCount: commercials.length,
      itemBuilder: (context, index) {
        final commercial = commercials[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _getAvatarColor(index),
                    child: Text(
                      commercials[index].comm![0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commercials[index].comm!.contains(widget.comms.nomCommerciaux!) ? "MOI" : commercial.comm!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Commission: ${NumberFormat("#,###,###,### CFA").format(commercial.chiffreAffaire)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < 3) _buildTrailingIcon(index),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildLoadingIndicator() {
    return const Center(
      child:  CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      ),
    );
  }

  Color _getAvatarColor(int index) {

    if (index == 0) return Colors.amber; // Première position
    if (index == 1) return Colors.grey; // Deuxième position
    if (index == 2) return Colors.brown; // Troisième position
    return Colors.blueAccent; // Autres positions
  }

  Widget _buildTrailingIcon(int index) {
    if (index == 0) {
      return const Icon(Icons.emoji_events, color: Colors.amber, size: 30);
    } else if (index == 1) {
      return const Icon(Icons.emoji_events, color: Colors.grey, size: 30);
    } else if (index == 2) {
      return const Icon(Icons.emoji_events, color: Colors.brown, size: 30);
    } else {
      return Container();
    }
  }

  Future<void> fetchRank() async {
    await _provider.rankingCommerciaux(
      secure: false,
      onSuccess: (r) {
        setState(() {
          commercials.clear(); // Clear previous data
          for (var element in r) {
            commercials.add(ChiffreAffaire.MapRanking(element));
          }
          isLoading = false;
        });
      },
      onError: (e) {
        setState(() {
          isLoading = false;
          previousPage(context);
        });
      },
    );
  }


}
