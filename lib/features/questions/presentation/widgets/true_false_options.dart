import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TrueFalseOptions extends StatefulWidget {
  final String? selectedTrueFalse;
  final Function(String) onChanged;
  final String? errorText;

  const TrueFalseOptions({
    super.key,
    required this.selectedTrueFalse,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<TrueFalseOptions> createState() => _TrueFalseOptionsState();
}

class _TrueFalseOptionsState extends State<TrueFalseOptions> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedTrueFalse;
  }

  @override
  void didUpdateWidget(TrueFalseOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTrueFalse != oldWidget.selectedTrueFalse) {
      setState(() {
        _selectedValue = widget.selectedTrueFalse;
      });
    }
  }

  void _handleTap(String value) {
    setState(() {
      _selectedValue = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bonne réponse',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap('vrai'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedValue == 'vrai'
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedValue == 'vrai'
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: _selectedValue == 'vrai'
                              ? Colors.white
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vrai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedValue == 'vrai'
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: _selectedValue == 'vrai'
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap('faux'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedValue == 'faux'
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedValue == 'faux'
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: _selectedValue == 'faux'
                              ? Colors.white
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Faux',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedValue == 'faux'
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: _selectedValue == 'faux'
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ✅ Affichage de l'erreur
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        if (_selectedValue != null && widget.errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Bonne réponse sélectionnée',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}