import '/config/app_config.dart';
import 'backend_auth.dart';
import '../shared/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/survey_model.dart';
import 'package:flutter/foundation.dart';

class LoginSurvey {
  Map<String, dynamic> questionsJSON = {
    'ageRange': questions[0].userAnswer,
    'gender': questions[1].userAnswer,
    'exerciseFrequency': questions[2].userAnswer,
    'exerciseTypes': questions[3].userAnswer,
    'socialFrequency': questions[4].userAnswer,
    'mainGoals': questions[5].userAnswer.isNotEmpty
        ? questions[5].userAnswer
        : 'No answer',
    'takesMedications': questions[6].userAnswer.split(',')[0] == 'Yes'
        ? true
        : false,
    'medicationDetails':
        questions[6].userAnswer.split(',').length > 1 &&
            questions[6].userAnswer.split(',')[1].trim().isNotEmpty
        ? questions[6].userAnswer.split(',')[1].trim()
        : 'No answer',
  };

  Future<bool> postSurvey() async {
    // Authenticate with your backend server
    final backendAuthResult = await BackendAuth().authenticateWithBackend(
      UserProvider.userIdToken ?? '',
      AppConfig.googleAuthUrl,
    );

    if (backendAuthResult) {
      // POST to the database
      final response = await http.post(
        Uri.parse(AppConfig.profileUrl),
        headers: BackendAuth().getAuthHeaders(),
        body: jsonEncode(questionsJSON),
      );

      if (response.statusCode == 200) {
        debugPrint("Survey posted successfully");
        return true;
      } else {
        debugPrint("Survey posting failed: Status code ${response.statusCode}");
        debugPrint("Error: ${response.body}");
        return false;
      }
    } else {
      debugPrint("Backend authentication failed");
      return false;
    }
  }
}
