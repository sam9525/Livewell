import 'package:flutter/material.dart';
import '../shared/shared.dart';
import '../services/onboarding_target_registry.dart';
import '../services/onboarding_constants.dart';
import 'widgets/spotlight_clipper.dart';

// Interactive onboarding that navigates to actual pages and highlights features
class InteractiveOnboarding extends StatefulWidget {
  final VoidCallback onComplete;
  final Function(String route) onNavigate;

  const InteractiveOnboarding({
    super.key,
    required this.onComplete,
    required this.onNavigate,
  });

  @override
  State<InteractiveOnboarding> createState() => _InteractiveOnboardingState();
}

class _InteractiveOnboardingState extends State<InteractiveOnboarding> {
  int _currentStep = 0;

  final List<OnboardingStepData> _steps = [
    OnboardingStepData(
      title: 'Welcome to LiveWell!',
      description: 'Let me show you around. Tap Next to begin the tour.',
      route: '/home',
      targetKey: null,
      position: OnboardingPosition.center,
    ),
    OnboardingStepData(
      title: 'Local Resources',
      description:
          'Find nearby health services, parks, and community resources right here!',
      route: '/home',
      targetKey: 'local_resources',
      position: OnboardingPosition.below,
    ),
    OnboardingStepData(
      title: 'Track Your Steps',
      description:
          'Your daily step progress is shown here. This updates in real-time as you walk!',
      route: '/home',
      targetKey: 'steps_widget',
      position: OnboardingPosition.below,
    ),
    OnboardingStepData(
      title: 'Water Intake',
      description:
          'Track your water intake throughout the day with these quick buttons.',
      route: '/home',
      targetKey: 'water_intake',
      position: OnboardingPosition.above,
    ),
    OnboardingStepData(
      title: 'Your Goals Recommendations',
      description: 'Here are some goals recommendations for you.',
      route: '/goal',
      targetKey: 'goal_recommendations',
      position: OnboardingPosition.center,
    ),
    OnboardingStepData(
      title: 'Apply Your Goals',
      description:
          'Apply your goals to your daily step and water intake targets here.',
      route: '/goal',
      targetKey: 'set_goals_button_by_recommendation',
      position: OnboardingPosition.center,
    ),
    OnboardingStepData(
      title: 'Customize Your Goals',
      description: 'Customize your daily step and water intake targets here.',
      route: '/goal',
      targetKey: 'customize_goals_button',
      position: OnboardingPosition.center,
    ),
    OnboardingStepData(
      title: 'Chat with Our Assistant',
      description:
          'Need help? Chat with our AI assistant anytime for health advice!',
      route: '/chatbot',
      targetKey: "chatbot",
      position: OnboardingPosition.center,
    ),
    OnboardingStepData(
      title: 'Your Profile',
      description:
          'View your information and complete your frailty assessment here.',
      route: '/profile',
      targetKey: 'frailty_button',
      position: OnboardingPosition.above,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Navigate to first step's route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_steps.isNotEmpty) {
        widget.onNavigate(_steps[_currentStep].route);
      }
    });
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      widget.onNavigate(_steps[_currentStep].route);
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      widget.onNavigate(_steps[_currentStep].route);
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    widget.onComplete();

    // Move to home page
    widget.onNavigate('/home');
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return OnboardingSpotlight(
      step: step,
      currentStepIndex: _currentStep,
      totalSteps: _steps.length,
      onNext: _nextStep,
      onPrevious: _previousStep,
      onSkip: _skip,
    );
  }
}

// Spotlight overlay that highlights specific UI elements
class OnboardingSpotlight extends StatefulWidget {
  final OnboardingStepData step;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  const OnboardingSpotlight({
    super.key,
    required this.step,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  @override
  State<OnboardingSpotlight> createState() => _OnboardingSpotlightState();
}

class _OnboardingSpotlightState extends State<OnboardingSpotlight>
    with SingleTickerProviderStateMixin {
  Rect? _spotlightRect;
  Rect? _previousSpotlightRect;
  late AnimationController _animationController;
  Animation<Rect?>? _spotlightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: OnboardingConstants.animationDuration,
      vsync: this,
    );
    _updateSpotlight();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OnboardingSpotlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.targetKey != widget.step.targetKey) {
      _updateSpotlight();
    }
  }

  void _updateSpotlight() {
    // Wait for next frame to ensure widget is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (widget.step.targetKey != null) {
        // First, scroll to make the target visible
        await OnboardingTargetRegistry.scrollToTarget(widget.step.targetKey!);

        // Wait a bit for the scroll to settle and layout to update
        await Future.delayed(OnboardingConstants.scrollSettleDelay);

        if (!mounted) return;

        // Now get the target position and animate spotlight
        final rect = OnboardingTargetRegistry.getTargetRect(
          widget.step.targetKey!,
        );
        if (rect != null && mounted) {
          _previousSpotlightRect = _spotlightRect;
          _spotlightRect = rect;

          // Create animation from previous to new position
          _spotlightAnimation =
              RectTween(
                begin: _previousSpotlightRect,
                end: _spotlightRect,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: OnboardingConstants.animationCurve,
                ),
              );

          // Start animation and rebuild
          _animationController.forward(from: 0.0);
          setState(() {});
        }
      } else {
        // Animate spotlight disappearing
        _previousSpotlightRect = _spotlightRect;
        _spotlightRect = null;

        _spotlightAnimation =
            RectTween(begin: _previousSpotlightRect, end: null).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: OnboardingConstants.animationCurve,
              ),
            );

        _animationController.forward(from: 0.0);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Get the current animated spotlight rect
        final animatedRect = _spotlightAnimation?.value ?? _spotlightRect;

        return Stack(
          children: [
            // Semi-transparent overlay with spotlight cutout
            Positioned.fill(
              child: ClipPath(
                clipper: SpotlightClipper(
                  spotlightRect: animatedRect,
                  padding: 8.0,
                  borderRadius: 12.0,
                ),
                child: Container(color: Colors.black.withValues(alpha: 0.75)),
              ),
            ),

            // Spotlight border highlight
            if (animatedRect != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: SpotlightBorderPainter(
                    spotlightRect: animatedRect,
                    padding: 8.0,
                    borderRadius: 12.0,
                  ),
                ),
              ),

            // Tooltip card
            _buildTooltipCard(context),
          ],
        );
      },
    );
  }

  Widget _buildTooltipCard(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate position based on spotlight and position enum
    double? top, bottom;
    final left = OnboardingConstants.tooltipHorizontalPadding;
    final right = OnboardingConstants.tooltipHorizontalPadding;

    if (_spotlightRect != null) {
      switch (widget.step.position) {
        case OnboardingPosition.above:
          // Position tooltip above the spotlight
          bottom =
              screenSize.height -
              _spotlightRect!.top +
              OnboardingConstants.tooltipSpacing;
        case OnboardingPosition.below:
          // Position tooltip below the spotlight
          top = _spotlightRect!.bottom + OnboardingConstants.tooltipSpacing;
        case OnboardingPosition.left:
        case OnboardingPosition.right:
        case OnboardingPosition.center:
          // Use default bottom position for center/left/right
          bottom = OnboardingConstants.tooltipDefaultBottomOffset;
      }
    } else {
      // No spotlight - use default bottom position
      bottom = OnboardingConstants.tooltipDefaultBottomOffset;
    }

    return AnimatedPositioned(
      duration: OnboardingConstants.animationDuration,
      curve: OnboardingConstants.animationCurve,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.step.title,
                style: Shared.fontStyle(26, FontWeight.bold, Shared.orange),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                widget.step.description,
                style: Shared.fontStyle(20, FontWeight.w400, Shared.black),
              ),

              const SizedBox(height: 20),

              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.totalSteps,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == widget.currentStepIndex
                          ? Shared.orange
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (widget.currentStepIndex > 0)
                    TextButton(
                      onPressed: widget.onPrevious,
                      child: Text(
                        'Back',
                        style: Shared.fontStyle(
                          24,
                          FontWeight.w500,
                          Shared.darkGray,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),

                  // Skip button
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'Skip Tour',
                      style: Shared.fontStyle(20, FontWeight.w400, Colors.grey),
                    ),
                  ),

                  // Next/Done button
                  ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Shared.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      widget.currentStepIndex < widget.totalSteps - 1
                          ? 'Next'
                          : 'Done',
                      style: Shared.fontStyle(
                        24,
                        FontWeight.bold,
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Onboarding step data model
class OnboardingStepData {
  final String title;
  final String description;
  final String route;
  final String? targetKey; // GlobalKey name for the target widget
  final OnboardingPosition position;

  const OnboardingStepData({
    required this.title,
    required this.description,
    required this.route,
    this.targetKey,
    required this.position,
  });
}

// Position of tooltip relative to target
enum OnboardingPosition { center, above, below, left, right }

// Wrapper widget to mark features for onboarding highlighting
class OnboardingTarget extends StatefulWidget {
  final String targetKey;
  final Widget child;

  const OnboardingTarget({
    super.key,
    required this.targetKey,
    required this.child,
  });

  @override
  State<OnboardingTarget> createState() => _OnboardingTargetState();
}

class _OnboardingTargetState extends State<OnboardingTarget> {
  @override
  Widget build(BuildContext context) {
    // Register this widget with the onboarding system using a GlobalKey
    return Container(
      key: OnboardingTargetRegistry.getKey(widget.targetKey),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    OnboardingTargetRegistry.unregisterKey(widget.targetKey);
    super.dispose();
  }
}
