import 'package:flutter/material.dart';

class OnboardingStepper extends StatelessWidget {
  final int currentStep; // 0: Language, 1: Location, 2: Notifications, 3: Personalize/Register

  const OnboardingStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          _buildStep(0, Icons.translate_rounded, 'Language'),
          _buildDivider(0),
          _buildStep(1, Icons.location_on_rounded, 'Location'),
          _buildDivider(1),
          _buildStep(2, Icons.notifications_rounded, 'Notifications'),
          _buildDivider(2),
          _buildStep(3, Icons.person_rounded, 'Personalize'),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, IconData icon, String label) {
    final isCompleted = stepIndex < currentStep;
    final isActive = stepIndex == currentStep;

    Color circleColor;
    Color borderColor;
    Widget childWidget;
    Color labelColor;

    if (isCompleted) {
      circleColor = const Color(0xFF15803D); // Green
      borderColor = const Color(0xFF15803D);
      childWidget = const Icon(Icons.check, color: Colors.white, size: 13);
      labelColor = const Color(0xFF15803D);
    } else if (isActive) {
      circleColor = const Color(0xFFFF671F); // Orange
      borderColor = const Color(0xFFFF671F);
      childWidget = Icon(icon, color: Colors.white, size: 13);
      labelColor = const Color(0xFFFF671F);
    } else {
      circleColor = Colors.white;
      borderColor = const Color(0xFFCBD5E1); // Grey border
      childWidget = Icon(icon, color: const Color(0xFF94A3B8), size: 13);
      labelColor = const Color(0xFF94A3B8);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF671F).withAlpha(35),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(child: childWidget),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider(int stepAfter) {
    final isCompleted = stepAfter < currentStep;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Align line vertically with center of 26px circle
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF15803D) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
