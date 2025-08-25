import 'package:flutter/material.dart';
import '../shared/shared.dart';

class Chatbot {
  static Container chatbotPage(BuildContext context) => Container(
    color: Shared.bgColor,
    child: SizedBox.expand(
      child: Center(
        child: Text(
          'Chatbot page',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
}
