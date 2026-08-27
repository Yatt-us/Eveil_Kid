import 'package:flutter/material.dart';
import 'package:eveilkid/features/admin/presentation/pages/admin/admin_tutoriel_form_page.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';

class AddTutorielScreen extends StatelessWidget {
  final Tutoriel? tutorielToEdit;
  final String? tutorielId;

  const AddTutorielScreen({
    super.key,
    this.tutorielToEdit,
    this.tutorielId,
  });

  @override
  Widget build(BuildContext context) {
    return AdminTutorielFormPage(
      tutorielToEdit: tutorielToEdit,
      tutorielId: tutorielId,
    );
  }
}