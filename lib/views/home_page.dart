import 'package:flutter/material.dart';
import '../shared/shared.dart';

class Home {
  static Container homePageText(BuildContext context) => Container(
    color: Shared.bgColor,
    child: SizedBox.expand(
      child: Center(
        child: Text('Home page', style: Theme.of(context).textTheme.titleLarge),
      ),
    ),
  );
}
