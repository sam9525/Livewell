import 'package:flutter/material.dart';
import '../../shared/shared.dart';
import '../../model/survey_model.dart';
import '../../auth/login_survey.dart';
import '../../views/navigation.dart';
import '../../shared/sign_in_out_shared.dart';

class SurveyProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;

  const SurveyProgressIndicator({
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

class SurveyOptionCard extends StatelessWidget {
  final SurveyModel question;
  final String option;
  final ValueChanged<String> onOptionSelected;
  final int questionIndex;
  final int totalQuestions;

  const SurveyOptionCard({
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

Widget buildTextField(BuildContext context, SurveyModel question) {
  return StatefulBuilder(
    builder: (context, setState) {
      final textController = TextEditingController(text: "");
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(color: Shared.orange, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          maxLines: 2,
          controller: textController,
          style: Shared.fontStyle(24, FontWeight.normal, Shared.black),
          decoration: InputDecoration(
            hintText: 'Enter medications name here...',
            hintStyle: Shared.fontStyle(
              24,
              FontWeight.normal,
              Shared.lightGray,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            question.userAnswer = "Yes, $value";
          },
        ),
      );
    },
  );
}

class SurveyNavigationButtons extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final SurveyModel currentQuestionModel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const SurveyNavigationButtons({
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
    final canProceed =
        currentQuestionModel.isAnswered || !currentQuestionModel.isRequired;

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
                        showDialog(
                          context: context,
                          builder: (context) {
                            return _buildSurveyAnswersDialog(context);
                          },
                        );
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
                isLastQuestion ? "Submit" : "Next",
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

  Widget _buildSurveyAnswersDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Shared.bgColor,
      title: const Text('Your Answers'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: questions.map((q) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(
                  style: Shared.fontStyle(18, FontWeight.bold, Shared.black),
                  children: [
                    TextSpan(
                      text: '${q.question}\n',
                      style: Shared.fontStyle(
                        18,
                        FontWeight.bold,
                        Shared.black,
                      ),
                    ),
                    TextSpan(
                      text: q.userAnswer.isNotEmpty
                          ? q.userAnswer
                          : 'No answer',
                      style: Shared.fontStyle(
                        18,
                        FontWeight.normal,
                        Shared.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            // POST answers to the database
            bool res = await LoginSurvey().postSurvey();
            if (res && context.mounted) {
              SignInOutShared.changePage(context, HomePage());
            }
          },
          child: Text(
            'OK',
            style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
          ),
        ),
      ],
    );
  }
}
