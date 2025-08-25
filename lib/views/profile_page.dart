import 'package:flutter/material.dart';
import '../shared/shared.dart';

class Profile {
  static Container profilePage(BuildContext context) => Container(
    color: Shared.bgColor,
    child: SizedBox.expand(
      child: Center(
        child: Text(
          'Profile page',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
}
