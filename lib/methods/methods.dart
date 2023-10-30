
import 'package:flutter/material.dart';

Future nextPage(BuildContext context, Widget page) async {
  await Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) {
        return page;
      }));
}


Future previousPage(BuildContext context) async {
  Navigator.pop(context);
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}