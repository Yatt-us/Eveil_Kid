import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String activityId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuestionCard({
    super.key,
    required this.question,
    required this.activityId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
        context.push(
          '/admin/activites/$activityId/questions/detail/${question.id}'
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          
          border: Border.all(color: const Color.fromARGB(255, 211, 210, 210)),
        ),
        child: Row(
          children: [
            
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              child: Text(
                '${question.ordre + 1}.',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    question.enonce,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 2, 2, 2),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      // Type de question
                      Text(
                        question.typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color.fromARGB(255, 41, 40, 40),
                        ),
                      ),
                      const Spacer(),
                      
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

           
            Icon(
              Icons.chevron_right,
              size: 24,
              color: Colors.black,
              fontWeight: FontWeight(300),
            ),
          ],
        ),
      ),
    );
  }
}