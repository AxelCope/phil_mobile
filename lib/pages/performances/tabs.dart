 import 'package:flutter/material.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/performances/dotation_charts.dart';
import 'package:phil_mobile/pages/performances/performances.dart';
import 'package:phil_mobile/pages/performances/reconversion_charts.dart';

class Performances extends StatefulWidget {
  const Performances({
    Key? key,
    required this.comms
  }) : super(key: key);

  final Comms comms;

  @override
  State<Performances> createState() => _PerformancesState();
}

class _PerformancesState extends State<Performances> {
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
            bottom: const TabBar(
              tabs: [
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



