import 'package:flutter/material.dart';

class TutorielAgeFilter extends StatelessWidget {
  final String selectedAge;
  final ValueChanged<String> onSelected;

  const TutorielAgeFilter({
    super.key,
    required this.selectedAge,
    required this.onSelected,
  });

  static const List<String> ages = [
    'Tous',
    'Age 4-6',
    'Age 7-9',
    'Age 10-12',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ages.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final age = ages[index];
          final selected = selectedAge == age;

          return GestureDetector(
            onTap: () {
              onSelected(age);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF7138C8)
                    : const Color(0xFFF3F2F7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                age,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selected
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}