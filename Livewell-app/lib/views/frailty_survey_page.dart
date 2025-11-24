import 'package:flutter/material.dart';
import '../shared/shared.dart';
import '../model/frailty_survey_model.dart';
import 'widgets/frailty_survey_widgets.dart';

class FrailtySurveyPage extends StatefulWidget {
  const FrailtySurveyPage({super.key});

  @override
  State<FrailtySurveyPage> createState() => _FrailtySurveyPageState();
}

class _FrailtySurveyPageState extends State<FrailtySurveyPage> {
  int currentQuestion = 0;
  final PageController _pageController = PageController();

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
      frailtyQuestions[currentQuestion].userAnswer = value;
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
    if (currentQuestion < frailtyQuestions.length - 1 &&
        frailtyQuestions[currentQuestion].isAnswered) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Shared.bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Shared.orange),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Frailty Assessment',
          style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                FrailtyProgressIndicator(
                  currentQuestion: currentQuestion,
                  totalQuestions: frailtyQuestions.length,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: frailtyQuestions.length,
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
            child: FrailtyNavigationButtons(
              currentQuestion: currentQuestion,
              totalQuestions: frailtyQuestions.length,
              currentQuestionModel: frailtyQuestions[currentQuestion],
              onPrevious: _goToPreviousPage,
              onNext: _goToNextPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = frailtyQuestions[index];
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
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                question.question,
                style: Shared.fontStyle(32, FontWeight.bold, Shared.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        // Check input type and render appropriate widget
        if (question.inputType == SurveyInputType.numericInput)
          FrailtyNumericInputCard(
            question: question,
            onValueChanged: _onAnswerSelected,
          )
        else
          ...question.options.map(
            (option) => FrailtyOptionCard(
              question: question,
              option: option,
              onOptionSelected: _onAnswerSelected,
              questionIndex: index,
              totalQuestions: frailtyQuestions.length,
            ),
          ),
      ],
    );
  }
}
