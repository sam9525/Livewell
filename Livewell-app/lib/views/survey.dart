import 'package:flutter/material.dart';
import '../shared/shared.dart';
import '../model/survey_model.dart';
import 'widgets/survey_widgets.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage>
    with AutomaticKeepAliveClientMixin<SurveyPage> {
  int currentQuestion = 0;
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentQuestion = index;
    });
  }

  void _onAnswerSelected(String value) {
    setState(() {
      questions[currentQuestion].userAnswer = value;
    });
  }

  void _goToPreviousPage() {
    if (currentQuestion > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _goToNextPage() {
    if (currentQuestion < questions.length - 1 &&
        (questions[currentQuestion].isAnswered ||
            !questions[currentQuestion].isRequired)) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Survey',
                  style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
                ),
                const SizedBox(height: 20),
                SurveyProgressIndicator(
                  currentQuestion: currentQuestion,
                  totalQuestions: questions.length,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: questions.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) => _buildQuestionPage(index),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SurveyNavigationButtons(
              currentQuestion: currentQuestion,
              totalQuestions: questions.length,
              currentQuestionModel: questions[currentQuestion],
              onPrevious: _goToPreviousPage,
              onNext: _goToNextPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = questions[index];
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.isRequired)
              Text(
                "*",
                style: Shared.fontStyle(32, FontWeight.bold, Colors.red),
              ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                question.question,
                style: Shared.fontStyle(32, FontWeight.bold, Shared.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ...question.options.map(
          (option) => SurveyOptionCard(
            question: question,
            option: option,
            onOptionSelected: _onAnswerSelected,
            questionIndex: index,
            totalQuestions: questions.length,
          ),
        ),
        if (question.isTextAnswer && question.userAnswer == "Yes") ...[
          buildTextField(context, question),
        ],
      ],
    );
  }
}
