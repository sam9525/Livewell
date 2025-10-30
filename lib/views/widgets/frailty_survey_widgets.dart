import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../model/frailty_survey_model.dart';
import '../../shared/user_provider.dart';
import '../../auth/profile_auth.dart';

class FrailtyNumericInputCard extends StatefulWidget {
  final FrailtySurveyModel question;
  final ValueChanged<String> onValueChanged;

  const FrailtyNumericInputCard({
    super.key,
    required this.question,
    required this.onValueChanged,
  });

  @override
  State<FrailtyNumericInputCard> createState() =>
      _FrailtyNumericInputCardState();
}

class _FrailtyNumericInputCardState extends State<FrailtyNumericInputCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.question.userAnswer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: Shared.fontStyle(24, FontWeight.bold, Shared.black),
      decoration: InputDecoration(
        suffixText: widget.question.unit,
        suffixStyle: Shared.fontStyle(20, FontWeight.bold, Shared.orange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Shared.orange, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Shared.orange, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Shared.orange, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        hintText: widget.question.question == "Height"
            ? "e.g., 170"
            : "e.g., 65",
        hintStyle: Shared.fontStyle(20, FontWeight.normal, Shared.lightGray),
      ),
      onChanged: (value) {
        widget.onValueChanged(value);
      },
    );
  }
}

class FrailtyProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;

  const FrailtyProgressIndicator({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              tween: Tween<double>(
                begin: 0.0,
                end: (currentQuestion + 1) / totalQuestions,
              ),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Shared.lightGray,
                  borderRadius: BorderRadius.circular(8),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Shared.orange,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left:
              ((currentQuestion + 1) / totalQuestions) *
                  MediaQuery.of(context).size.width -
              MediaQuery.of(context).size.width,
          right: 0,
          child: Center(
            child: Text(
              '${currentQuestion + 1}/$totalQuestions',
              style: Shared.fontStyle(12, FontWeight.bold, Shared.bgColor),
            ),
          ),
        ),
      ],
    );
  }
}

class FrailtyOptionCard extends StatelessWidget {
  final FrailtySurveyModel question;
  final String option;
  final ValueChanged<String> onOptionSelected;
  final int questionIndex;
  final int totalQuestions;

  const FrailtyOptionCard({
    super.key,
    required this.question,
    required this.option,
    required this.onOptionSelected,
    required this.questionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> selectedOptions = question.userAnswer.isNotEmpty
        ? question.userAnswer.split(',')
        : [];
    final isSelected = selectedOptions.contains(option);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            question.isMultiple
                ? _buildCheckbox(
                    context,
                    option,
                    isSelected,
                    selectedOptions,
                    onOptionSelected,
                  )
                : _buildRadio(
                    context,
                    option,
                    isSelected,
                    selectedOptions,
                    onOptionSelected,
                  ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCheckbox(
  BuildContext context,
  String option,
  bool isSelected,
  List<String> selectedOptions,
  ValueChanged<String> onOptionSelected,
) {
  return Container(
    decoration: BoxDecoration(
      color: isSelected ? Shared.orange : Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(15)),
    ),
    child: CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      title: Text(
        option,
        style: Shared.fontStyle(
          24,
          FontWeight.bold,
          isSelected ? Colors.white : Shared.orange,
        ),
      ),
      value: isSelected,
      onChanged: (bool? value) {
        List<String> updatedOptions = List.from(selectedOptions);
        if (value == true) {
          if (!updatedOptions.contains(option)) {
            updatedOptions.add(option);
          }
        } else {
          updatedOptions.remove(option);
        }
        onOptionSelected(updatedOptions.join(','));
      },
      activeColor: Shared.bgColor,
      checkColor: Shared.orange,
      selected: isSelected,
    ),
  );
}

Widget _buildRadio(
  BuildContext context,
  String option,
  bool isSelected,
  List<String> selectedOptions,
  ValueChanged<String> onOptionSelected,
) {
  return Container(
    decoration: BoxDecoration(
      color: isSelected ? Shared.orange : Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(15)),
    ),
    child: RadioListTile<String>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      title: Text(
        option,
        style: Shared.fontStyle(
          24,
          FontWeight.bold,
          isSelected ? Colors.white : Shared.orange,
        ),
      ),
      value: option,
      activeColor: Shared.bgColor,
      groupValue: selectedOptions.isNotEmpty ? selectedOptions.first : null,
      onChanged: (value) => onOptionSelected(value!),
    ),
  );
}

class FrailtyNavigationButtons extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final FrailtySurveyModel currentQuestionModel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const FrailtyNavigationButtons({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.currentQuestionModel,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final showPreviousButton =
        currentQuestion > 0 || currentQuestion == totalQuestions - 1;
    final isLastQuestion = currentQuestion == totalQuestions - 1;
    final canProceed = currentQuestionModel.isAnswered;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        height: 52,
        margin: const EdgeInsets.only(top: 24, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showPreviousButton) ...[
              ElevatedButton(
                onPressed: currentQuestion > 0 ? onPrevious : null,
                style: Shared.buttonStyle(
                  MediaQuery.of(context).size.width * 0.42,
                  52,
                  Colors.white,
                  Colors.white,
                ),
                child: Text(
                  "Previous",
                  style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
                ),
              ),
              const SizedBox(width: 20),
            ],
            ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (isLastQuestion) {
                        _finishSurvey(context);
                      } else {
                        onNext();
                      }
                    }
                  : null,
              style: Shared.buttonStyle(
                _getButtonWidth(context),
                52,
                Shared.orange,
                Colors.white,
              ),
              child: Text(
                isLastQuestion ? "Finish" : "Next",
                style: Shared.fontStyle(24, FontWeight.bold, Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getButtonWidth(BuildContext context) {
    if (currentQuestion == 0 && currentQuestion < totalQuestions - 1) {
      return MediaQuery.of(context).size.width - 40;
    }
    return MediaQuery.of(context).size.width * 0.42;
  }

  void _finishSurvey(BuildContext context) async {
    // Calculate frailty score
    final score = _calculateFrailtyScore();

    // Update the user provider with the new frailty score
    Provider.of<UserProvider>(context, listen: false).updateFrailtyScore(score);

    // Show loading indicator while updating API
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Shared.orange),
                const SizedBox(height: 16),
                Text(
                  'Saving your results...',
                  style: Shared.fontStyle(18, FontWeight.normal, Shared.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Update frailty score via API
    final updateSuccess = await ProfileAuth.updateFrailtyScore(score);

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Show completion dialog with API update status
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => _buildCompletionDialog(context, score, updateSuccess),
      );
    }
  }

  // Helper functions for BMI calculation
  double calculateBMI(List<FrailtySurveyModel> questions) {
    // Find height and weight answers
    final heightQuestion = questions.firstWhere(
      (q) => q.question == "Height",
      orElse: () => FrailtySurveyModel(question: ""),
    );
    final weightQuestion = questions.firstWhere(
      (q) => q.question == "Weight",
      orElse: () => FrailtySurveyModel(question: ""),
    );

    // Parse values
    final height = double.tryParse(heightQuestion.userAnswer);
    final weight = double.tryParse(weightQuestion.userAnswer);

    // Calculate BMI: weight(kg) / (height(m))^2
    final heightInMeters = height! / 100;
    final bmi = weight! / (heightInMeters * heightInMeters);

    return bmi;
  }

  double _calculateFrailtyScore() {
    double score = 0.0;
    int totalPoints = 0;
    int maxPoints = 0;

    for (var question in frailtyQuestions) {
      if (!question.isAnswered) continue;

      final answer = question.userAnswer;
      final questionText = question.question;

      // Daily Living Tasks (higher score for more help needed)
      if (questionText.contains("Do you need help")) {
        final helpCount = answer
            .split(',')
            .where((a) => a != "None of the above")
            .length;
        totalPoints += helpCount * 2; // 2 points per activity
        maxPoints += 22; // 11 activities * 2 points
      }
      // Mood and Feelings (negative feelings increase score)
      else if (questionText.contains("feel happy")) {
        if (answer == "Rarely") {
          totalPoints += 3;
        } else if (answer == "Sometimes") {
          totalPoints += 2;
        }
        maxPoints += 3;
      } else if (questionText.contains("effort") ||
          questionText.contains("depressed") ||
          questionText.contains("lonely")) {
        if (answer == "Most times") {
          totalPoints += 3;
        } else if (answer == "Sometimes") {
          totalPoints += 2;
        }
        maxPoints += 3;
      }
      // Comorbidities (more conditions = higher score)
      else if (questionText.contains("Do you have any of these conditions")) {
        final conditions = answer
            .split(',')
            .where((c) => c != "None of the above")
            .length;
        totalPoints += conditions * 3; // 3 points per condition
        maxPoints += 21; // 7 conditions * 3 points
      }
      // High blood pressure
      else if (questionText.contains("high blood pressure")) {
        if (answer == "Yes") {
          totalPoints += 2;
        }
        maxPoints += 2;
      }
      // Weight change
      else if (questionText.contains("weight changed")) {
        if (answer == "Lost more than 10 lb") {
          totalPoints += 3;
        }
        maxPoints += 3;
      }
      // Self-rated health
      else if (questionText.contains("rate your overall health")) {
        if (answer == "Poor") {
          totalPoints += 5;
        } else if (answer == "Fair") {
          totalPoints += 4;
        } else if (answer == "Good") {
          totalPoints += 2;
        } else if (answer == "Very good") {
          totalPoints += 1;
        }
        maxPoints += 5;
      }
      // BMI calculation
      final bmi = calculateBMI(frailtyQuestions);
      if (bmi < 18.5) {
        totalPoints += 2;
      } else if (bmi < 25) {
        totalPoints += 1;
      } else if (bmi < 30) {
        totalPoints += 2;
      } else {
        totalPoints += 3;
      }
      maxPoints += 3;
    }

    // Calculate normalized score (0-5 scale)
    if (maxPoints > 0) {
      score = (totalPoints / maxPoints) * 5;
    }

    return score;
  }

  Widget _buildCompletionDialog(
    BuildContext context,
    double score,
    bool apiUpdateSuccess,
  ) {
    String status;
    String message;

    if (score < 1.5) {
      status = "Robust";
      message = "You're doing great! Keep maintaining your healthy lifestyle.";
    } else if (score < 2.5) {
      status = "Pre-frail";
      message = "Consider some lifestyle improvements to maintain your health.";
    } else {
      status = "Frail";
      message =
          "We recommend consulting with a healthcare provider for personalized guidance.";
    }

    return AlertDialog(
      backgroundColor: Shared.bgColor,
      title: Text(
        'Frailty Assessment Complete',
        style: Shared.fontStyle(24, FontWeight.bold, Shared.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your Frailty Score:',
            style: Shared.fontStyle(20, FontWeight.normal, Shared.black),
          ),
          const SizedBox(height: 10),
          Text(
            score.toStringAsFixed(1),
            style: Shared.fontStyle(48, FontWeight.bold, Shared.orange),
          ),
          const SizedBox(height: 10),
          Text(
            'Status: $status',
            style: Shared.fontStyle(24, FontWeight.bold, Shared.black),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: Shared.fontStyle(18, FontWeight.normal, Shared.black),
            textAlign: TextAlign.center,
          ),
          if (!apiUpdateSuccess) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your score was saved locally but could not be synced to the server.',
                      style: Shared.fontStyle(14, FontWeight.normal, Shared.black),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Return to profile page
          },
          child: Text(
            'Return to Profile',
            style: Shared.fontStyle(20, FontWeight.bold, Shared.orange),
          ),
        ),
      ],
    );
  }
}
