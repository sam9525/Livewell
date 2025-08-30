class SurveyModel {
  final String question;
  final List<String> options;
  final bool isRequired;
  final bool isMultiple;
  final bool isTextAnswer;
  String userAnswer;

  SurveyModel({
    required this.question,
    required this.options,
    this.isRequired = false,
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
    isRequired: true,
    question: "Age Range",
    options: ["41 - 50", "51 - 60", "61 - 70", "71 - 80", "81 - 90"],
  ),
  SurveyModel(
    isRequired: true,
    question: "Gender",
    options: ["Male", "Female"],
  ),
  SurveyModel(
    isRequired: true,
    question: "How often do you exercise a week?",
    options: [
      "Once a week",
      "2-3 times a week",
      "4-5 times a week",
      "6-7 times a week",
    ],
  ),
  SurveyModel(
    isRequired: true,
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
    isRequired: true,
    question: "How often do you go social activities a week?",
    options: [
      "Rarely",
      "Once a week",
      "2-3 times a week",
      "4-5 times a week",
      "6-7 times a week",
    ],
  ),
  SurveyModel(
    isRequired: false,
    question: "Main goals or interests?",
    isMultiple: true,
    options: [
      "Get fitter",
      "Improve mental wellbeing",
      "Meet new people",
      "Manage health condition",
      "Just exploring",
    ],
  ),
  SurveyModel(
    isRequired: true,
    question: "Do you take any regular medications?",
    isTextAnswer: true,
    options: ["Yes", "No"],
  ),
];
