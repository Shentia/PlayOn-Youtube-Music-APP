/*
 Playonworld
Version 2
*/

import 'package:flutter/material.dart';

Widget homeDrawer({
  required BuildContext context,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
}) {
  return Padding(
    padding: padding,
    child: Transform.rotate(
      angle: 22 / 7 * 2,
      child: IconButton(
        icon: const Icon(
          Icons.horizontal_split_rounded,
        ),
        // color: Theme.of(context).iconTheme.color,
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      ),
    ),
  );
}
