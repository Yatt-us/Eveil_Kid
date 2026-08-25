import 'package:flutter/material.dart';

class CheckoutStepper extends StatelessWidget {
  final int stepActuel; // 1: Adresse, 2: Paiement, 3: Confirmation

  const CheckoutStepper({super.key, required this.stepActuel});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF7E3DBE);
    const Color successColor = Color(0xFF289F51);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, 'Adresse', stepActuel, primaryColor, successColor),
          _buildLine(1, stepActuel, primaryColor, successColor),
          _buildStep(2, 'Paiement', stepActuel, primaryColor, successColor),
          _buildLine(2, stepActuel, primaryColor, successColor),
          _buildStep(3, 'Confirmation', stepActuel, primaryColor, successColor),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String title, int current, Color primary, Color success) {
    bool isDone = step < current;
    bool isCurrent = step == current;

    Color circleColor = isDone ? success : (isCurrent ? primary : Colors.grey.shade300);
    Color textColor = isCurrent || isDone ? Colors.black87 : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: circleColor,
          child: isDone
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '$step',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: textColor, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildLine(int step, int current, Color primary, Color success) {
    bool isDone = step < current;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        color: isDone ? success : Colors.grey.shade300,
      ),
    );
  }
}