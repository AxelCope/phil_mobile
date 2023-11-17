// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:phil_mobile/models/segmentation.dart';
// import 'package:phil_mobile/models/users.dart';
// import 'package:phil_mobile/provider/queries_provider.dart';
// import 'package:phil_mobile/widget/card.dart';
//
// class ActiviteGene extends StatefulWidget {
//   const ActiviteGene({
//     Key? key,
//     required this.comms,
//   }) : super(key: key);
//
//   final Comms comms;
//
//   @override
//   State<ActiviteGene> createState() => _ActiviteGeneState();
// }
//
// class _ActiviteGeneState extends State<ActiviteGene>
//     with AutomaticKeepAliveClientMixin {
//   DateTime date = DateTime.now();
//
//
//
//   String filename = '';
//   late final QueriesProvider _provider;
//
//   @override
//   void initState() {
//     super.initState();
//     _initProvider();
//   }
//
//   void _initProvider() async {
//     _provider = await QueriesProvider.instance;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return allSegments();
//   }
//
//
//
//   @override
//   bool get wantKeepAlive => true;
// }
