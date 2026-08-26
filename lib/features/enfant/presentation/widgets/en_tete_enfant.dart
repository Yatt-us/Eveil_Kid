import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:flutter/material.dart';

class EnTeteEnfant extends StatelessWidget {
  final EnfantModel enfant;

  const EnTeteEnfant({
    super.key,
    required this.enfant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFB98CFF),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: enfant.avatarUrl != null &&
                    enfant.avatarUrl!.isNotEmpty
                ? Image.network(
                    enfant.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return _avatarParDefaut();
                    },
                  )
                : _avatarParDefaut(),
          ),
        ),

        const SizedBox(width: 12),

        // Texte
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salut ${enfant.nom} !',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Bienvenue dans ton espace enfant',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '${enfant.age} ans',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF22A653),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarParDefaut() {
    return Container(
      color: const Color(0xFFEDE7F6),
      child: const Icon(
        Icons.child_care,
        size: 34,
        color: Color(0xFF8B5CF6),
      ),
    );
  }
}