import 'package:flutter/material.dart';
import '../shared/shared.dart';

class Notice {
  static Container noticePage(BuildContext context) => Container(
    color: Shared.bgColor,
    child: SizedBox.expand(
      child: Center(
        child: Text(
          'Notice page',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
}
