import 'package:flutter/material.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';

class TutorielSearchField extends StatelessWidget {
  const TutorielSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Rechercher un tutoriel...',
    this.onClear,
    this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      onFilterTap: onFilterTap,
    );
  }
}
