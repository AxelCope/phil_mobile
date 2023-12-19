import 'package:flutter/material.dart';

class CardHighlight extends StatefulWidget {
  const CardHighlight({
    Key? key,
    this.backgroundColor,
    required this.child,
    required this.codeSnippet,
    required this.header,
  }) : super(key: key);

  final Widget child;
  final Widget codeSnippet;
  final Widget header;
  final Color? backgroundColor;

  @override
  State<CardHighlight> createState() => _CardHighlightState();
}

class _CardHighlightState extends State<CardHighlight>
    with AutomaticKeepAliveClientMixin<CardHighlight> {
  bool isOpen = false;
  bool isCopying = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0), // Ajuste le padding du titre
        title:
          widget.child,
        onExpansionChanged: (state) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (mounted) setState(() => isOpen = state);
          });
        },
        trailing: const Icon(null),
        iconColor: Colors.blue, // Couleur de l'icône
        collapsedIconColor: Colors.grey, // Couleur de l'icône lorsque l'ExpansionTile est fermé
        leading: Icon(
          isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: isOpen ? Colors.blue : Colors.grey, // Couleur de l'icône en fonction de l'état d'expansion
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.codeSnippet,
          ),
        ],
      ),
    );



  }

  @override
  bool get wantKeepAlive => true;
}
