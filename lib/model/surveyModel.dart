class SurveyModel {
  final String question;
  final List<String> options;
  final bool isMultiple;
  final bool isTextAnswer;
  String userAnswer;

  SurveyModel({
    required this.question,
    required this.options,
    this.isMultiple = false,
    this.isTextAnswer = false,
    this.userAnswer = "",
  });

  bool get isAnswered => userAnswer.isNotEmpty;

  @override
  String toString() {
    return 'SurveyModel(question: $question, options: $options, userAnswer: $userAnswer)';
  }
}

final List<SurveyModel> questions = [
  SurveyModel(
    question: "Age Range",
    options: ["41 - 50", "51 - 60", "61 - 70", "71 - 80", "81 - 90"],
  ),
  SurveyModel(question: "Gender", options: ["Male", "Female"]),
  SurveyModel(
    question: "How often do you exercise a week?",
    options: [
      "once a week",
      "2-3 times a week",
      "4-5 times a week",
      "6-7 times a week",
    ],
  ),
  SurveyModel(
    question: "What kind of exercise do you do?",
    isMultiple: true,
    options: [
      "Running",
      "Jogging",
      "Walking",
      "Cycling",
      "Swimming",
      "Yoga",
      "Workout",
    ],
  ),
  SurveyModel(
    question: "How often do you go social activities a week?",
    options: [
      "Rarely",
      "once a week",
      "2-3 times a week",
      "4-5 times a week",
      "6-7 times a week",
    ],
  ),
  SurveyModel(
    question: "Do you take any regular medications?",
    isTextAnswer: true,
    options: ["Yes", "No"],
  ),
];
