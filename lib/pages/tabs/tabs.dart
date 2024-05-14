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

class _TabsState extends State<Tabs> with TickerProviderStateMixin{
  bool gotObjectif = false;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: tabController.index == 0,
      onPopInvoked: (bool value) {
        if (!value) {
          setState(() {
            tabController.index = 0;
          }
          );
        }
      },
      child: DefaultTabController(length: 3,
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
                controller: tabController,
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
              controller: tabController,
              children: [
                DetailsDotations(comms: widget.comms),
                DetailsReconversion(comms: widget.comms),
                ProgressionObjectif(comms: widget.comms)
              ],
            ),
          ),
      ),
    );
  }
}



