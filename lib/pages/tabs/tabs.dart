 import 'package:flutter/material.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/pages/services/performances/page_dotation_charts.dart';
import 'package:phil_mobile/pages/services/performances/page_activites.dart';
import 'package:phil_mobile/pages/services/performances/page_reconversion_charts.dart';

class Tabs extends StatefulWidget {
  const Tabs({
    Key? key,
    required this.comms
  }) : super(key: key);

  final Comms comms;

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  bool gotObjectif = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  previousPage(context);
                }
            ),
            title: const Text('Performances'),
            bottom: TabBar(
              labelColor: Colors.black,
             indicatorColor: philMainColor,
              tabs: const [
                Tab(text: 'Dotations'),
                Tab(text: 'Reconversions'),
                Tab(text: 'Progression'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DetailsDotations(comms: widget.comms),
              DetailsReconversion(comms: widget.comms),
              ProgressionObjectif(comms: widget.comms)
            ],
          ),
        ),
    );
  }
}



