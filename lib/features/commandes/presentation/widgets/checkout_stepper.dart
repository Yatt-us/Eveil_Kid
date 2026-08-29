import 'package:flutter/material.dart';

class CheckoutStepper extends StatelessWidget {
  final int stepActuel; // 1: Adresse, 2: Paiement, 3: Confirmation

  const CheckoutStepper({super.key, required this.stepActuel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    const success = Color(0xFF10B981);

    final steps = [
      const _StepData(step: 1, label: 'Adresse', icon: Icons.location_on_rounded),
      const _StepData(step: 2, label: 'Paiement', icon: Icons.credit_card_rounded),
      const _StepData(step: 3, label: 'Confirmation', icon: Icons.verified_rounded),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepItem(
              data: steps[i],
              currentStep: stepActuel,
              primary: primary,
              success: success,
              theme: theme,
              isDark: isDark,
            ),
            if (i < steps.length - 1)
              Expanded(
                child: _buildProgressLine(
                  stepIndex: i + 1,
                  currentStep: stepActuel,
                  success: success,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required _StepData data,
    required int currentStep,
    required Color primary,
    required Color success,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isCompleted = data.step < currentStep;
    final isCurrent = data.step == currentStep;

    Color iconBg;
    Color iconColor;
    Widget iconWidget;

    if (isCompleted) {
      iconBg = success;
      iconColor = Colors.white;
      iconWidget = const Icon(Icons.check_rounded, size: 14, color: Colors.white);
    } else if (isCurrent) {
      iconBg = primary;
      iconColor = Colors.white;
      iconWidget = Icon(data.icon, size: 14, color: Colors.white);
    } else {
      iconBg = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05);
      iconColor = isDark ? Colors.white38 : Colors.black38;
      iconWidget = Text(
        '${data.step}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: iconColor,
        ),
      );
    }

    final labelColor = isCurrent
        ? primary
        : (isCompleted
            ? (theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface)
            : (isDark ? Colors.white38 : Colors.black38));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? primary.withValues(alpha: 0.4)
                  : (isCompleted
                      ? success.withValues(alpha: 0.4)
                      : theme.dividerColor.withValues(alpha: 0.2)),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(height: 5),
        Text(
          data.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.w600 : FontWeight.w500),
            color: labelColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine({
    required int stepIndex,
    required int currentStep,
    required Color success,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isDone = stepIndex < currentStep;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 6, right: 6),
      child: Container(
        height: 2.5,
        decoration: BoxDecoration(
          color: isDone
              ? success
              : (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StepData {
  final int step;
  final String label;
  final IconData icon;

  const _StepData({
    required this.step,
    required this.label,
    required this.icon,
  });
}