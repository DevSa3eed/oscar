import 'package:flutter/material.dart';

class DutyQuestion {
  final String id;
  final String question;
  final String description;
  final IconData icon;
  final bool
  isPositive; // true for positive questions (Present), false for negative questions (Absent)
  final DutyQuestionState requiredState;
  final DutyQuestionState? nextStateYes;
  final DutyQuestionState? nextStateNo;

  const DutyQuestion({
    required this.id,
    required this.question,
    required this.description,
    required this.icon,
    required this.isPositive,
    required this.requiredState,
    this.nextStateYes,
    this.nextStateNo,
  });
}

enum DutyQuestionState {
  initial,
  present,
  absent,
  alertAndVigilant,
  hasIssues,
  completed,
}

class DutyQuestionWidget extends StatelessWidget {
  final DutyQuestion question;
  final bool isVisible;
  final bool isAnswered;
  final bool? answerValue; // true for Yes, false for No, null if not answered
  final bool
  isCurrentQuestion; // true if this is the current question to answer
  final bool shouldMinimize; // true if this question should be shown minimized
  final Function(String questionId, bool answer) onAnswer;
  final Function(String questionId)?
  onEdit; // Callback for editing answered questions

  const DutyQuestionWidget({
    super.key,
    required this.question,
    required this.isVisible,
    required this.isAnswered,
    this.answerValue,
    required this.isCurrentQuestion,
    required this.shouldMinimize,
    required this.onAnswer,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    // Show minimized version if should minimize
    if (shouldMinimize) {
      return _buildMinimizedCard(context);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      question.icon,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Yes/No Buttons
                  Row(
                    children: [
                      // No Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isCurrentQuestion
                              ? () => onAnswer(question.id, false)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrentQuestion
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            foregroundColor: isCurrentQuestion
                                ? Colors.red
                                : Colors.grey,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isCurrentQuestion
                                    ? Colors.red.withValues(alpha: 0.3)
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'No',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Yes Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isCurrentQuestion
                              ? () => onAnswer(question.id, true)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrentQuestion
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            foregroundColor: isCurrentQuestion
                                ? Colors.green
                                : Colors.grey,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isCurrentQuestion
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Yes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Check mark overlay for answered questions
          if (isAnswered)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: answerValue == true ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  answerValue == true ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMinimizedCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit != null ? () => onEdit!(question.id) : null,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity, // Full width like rolled up animation
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: answerValue == true
                  ? Colors.green.withValues(alpha: 0.05)
                  : Colors.red.withValues(alpha: 0.05),
              border: Border.all(
                color: answerValue == true
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: answerValue == true
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    question.icon,
                    color: answerValue == true ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Question text
                Expanded(
                  child: Text(
                    question.question,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),

                // Answer indicator
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: answerValue == true ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    answerValue == true ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
