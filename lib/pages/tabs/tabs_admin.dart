import 'package:flutter/material.dart';
import 'package:phil_mobile/pages/browse_page/browse.dart';
import 'package:phil_mobile/pages/browse_page/univers.dart';
import 'package:phil_mobile/pages/consts.dart';

class TabsAdmin extends StatefulWidget {
  const TabsAdmin({
    Key? key,
  }) : super(key: key);


  @override
  State<TabsAdmin> createState() => _TabsAdminState();
}

class _TabsAdminState extends State<TabsAdmin> {
  bool gotObjectif = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2,
      child: Scaffold(
          appBar: AppBar(
           title: Text("Généralités"),
            bottom: TabBar(
              labelColor: Colors.black,
              indicatorColor: philMainColor,
              tabs: const [
                Tab(text: 'Univers'),
                Tab(text: 'Chiffres'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              UniversAdmin(),
              BrowsePage()
            ],
          ),
        ),
      );
  }
}



