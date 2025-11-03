import 'package:flutter/material.dart';
import 'widgets/goal_widgets.dart';
import 'widgets/recommendations_list.dart';
import 'interactive_onboarding.dart';

class Goal extends StatelessWidget {
  const Goal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // AI Recommendations Section
                OnboardingTarget(
                  targetKey: 'goal_recommendations',
                  child: const RecommendationsList(),
                ),

                SizedBox(height: 20),
                OnboardingTarget(
                  targetKey: 'customize_goals_button',
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: NumberPicker(
                          title: "Daily water intake (ml)",
                          begin: 500,
                          end: 4000,
                          jump: 50,
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: NumberPicker(
                          title: "Daily steps",
                          begin: 2000,
                          end: 120000,
                          jump: 100,
                          isWaterIntake: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
