enum SurveyInputType { numericInput }

class FrailtySurveyModel {
  final String question;
  final List<String> options;
  final bool isRequired;
  final bool isMultiple;
  final SurveyInputType inputType;
  final String? unit;
  String userAnswer;

  FrailtySurveyModel({
    required this.question,
    this.options = const [],
    this.isRequired = true,
    this.isMultiple = false,
    this.inputType = SurveyInputType.numericInput,
    this.unit,
    this.userAnswer = "",
  });

  bool get isAnswered => userAnswer.isNotEmpty;

  @override
  String toString() {
    return 'FrailtySurveyModel(question: $question, options: $options, userAnswer: $userAnswer)';
  }
}

// Frailty assessment questions based on frailty_score_model.dart
final List<FrailtySurveyModel> frailtyQuestions = [
  // Basic Characteristics
  FrailtySurveyModel(
    question: "Height",
    inputType: SurveyInputType.numericInput,
    unit: "cm",
  ),
  FrailtySurveyModel(
    question: "Weight",
    inputType: SurveyInputType.numericInput,
    unit: "kg",
  ),

  // Daily Living Tasks
  FrailtySurveyModel(
    question: "Do you need help with the following activities?",
    isMultiple: true,
    options: [
      "Bathing",
      "Getting in/out of bed or chair",
      "Dressing",
      "Eating",
      "Grooming (hair, shaving, brushing teeth)",
      "Walking around the house",
      "Using the toilet",
      "Preparing meals",
      "Taking medications",
      "Shopping",
      "Managing finances",
      "None of the above",
    ],
  ),

  // Mood and Feelings
  FrailtySurveyModel(
    question: "How often do you feel happy?",
    options: ["Most times", "Sometimes", "Rarely"],
  ),
  FrailtySurveyModel(
    question: "How often do you feel everything is an effort?",
    options: ["Most times", "Sometimes", "Rarely"],
  ),
  FrailtySurveyModel(
    question: "How often do you feel depressed?",
    options: ["Most times", "Sometimes", "Rarely"],
  ),
  FrailtySurveyModel(
    question: "How often do you feel lonely?",
    options: ["Most times", "Sometimes", "Rarely"],
  ),

  // Comorbidities
  FrailtySurveyModel(
    question: "Do you have any of these conditions?",
    isMultiple: true,
    options: [
      "Arthritis",
      "Cancer",
      "Congestive heart failure",
      "Chronic lung disease",
      "Diabetes",
      "Stroke",
      "Heart attack",
      "None of the above",
    ],
  ),

  // On Examination
  FrailtySurveyModel(
    question: "Do you have high blood pressure?",
    options: ["Yes", "No"],
  ),
  FrailtySurveyModel(
    question: "Has your weight changed in the past year?",
    options: ["Lost more than 10 lb", "No significant change"],
  ),
  FrailtySurveyModel(
    question: "How would you rate your overall health?",
    options: ["Excellent", "Very good", "Good", "Fair", "Poor"],
  ),
];
