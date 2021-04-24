import 'package:flutter/material.dart';

class CardListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final void Function()? onTap;

  const CardListTile({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.elevation = 1,
    this.margin = EdgeInsets.zero,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color,
      margin: margin,
      child: ListTile(
        onTap: onTap,
        leading: leading,
        trailing: trailing,
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}
