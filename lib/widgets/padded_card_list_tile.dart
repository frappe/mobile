import 'package:flutter/material.dart';

import 'card_list_tile.dart';

class PaddedCardListTile extends StatelessWidget {
  final String title;
  final void Function() onTap;

  const PaddedCardListTile({
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 8.0,
      ),
      child: CardListTile(
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
