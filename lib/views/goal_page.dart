import 'package:flutter/material.dart';
import '../shared/shared.dart';

class Goal {
  static Container goalPage(BuildContext context) => Container(
    color: Shared.bgColor,
    child: SizedBox.expand(
      child: Center(
        child: Text('Goal page', style: Theme.of(context).textTheme.titleLarge),
      ),
    ),
  );
}
