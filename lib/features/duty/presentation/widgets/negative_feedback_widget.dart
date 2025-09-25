import 'package:flutter/material.dart';

class NegativeFeedbackOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const NegativeFeedbackOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class NegativeFeedbackWidget extends StatelessWidget {
  final Set<String> selectedFeedbacks;
  final Function(String feedbackId, bool isSelected) onFeedbackChanged;
  final Function() onSubmit;

  const NegativeFeedbackWidget({
    super.key,
    required this.selectedFeedbacks,
    required this.onFeedbackChanged,
    required this.onSubmit,
  });

  static const List<NegativeFeedbackOption> _feedbackOptions = [
    NegativeFeedbackOption(
      id: 'sleeping',
      title: 'Sleeping',
      description: 'Person was sleeping or dozing off',
      icon: Icons.bedtime,
    ),
    NegativeFeedbackOption(
      id: 'on_phone',
      title: 'On Phone',
      description: 'Person was using their phone inappropriately',
      icon: Icons.phone,
    ),
    NegativeFeedbackOption(
      id: 'not_wearing_vest',
      title: 'Not Wearing Vest',
      description: 'Person was not wearing required safety vest',
      icon: Icons.checkroom,
    ),
    NegativeFeedbackOption(
      id: 'late_arrival',
      title: 'Late Arrival',
      description: 'Person arrived late to their duty post',
      icon: Icons.schedule,
    ),
    NegativeFeedbackOption(
      id: 'inappropriate_behavior',
      title: 'Inappropriate Behavior',
      description: 'Person displayed inappropriate behavior',
      icon: Icons.warning,
    ),
    NegativeFeedbackOption(
      id: 'not_focused',
      title: 'Not Focused',
      description: 'Person was not paying attention to their duties',
      icon: Icons.visibility_off,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.warning, size: 24, color: Colors.orange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Issues Observed',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Feedback Options
              ..._feedbackOptions.map(
                (option) => _buildFeedbackOption(context, option),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedFeedbacks.isNotEmpty ? onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFeedbacks.isNotEmpty
                        ? Colors.orange
                        : Colors.grey.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    elevation: selectedFeedbacks.isNotEmpty ? 2 : 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Submit Issues',
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
        ),
      ),
    );
  }

  Widget _buildFeedbackOption(
    BuildContext context,
    NegativeFeedbackOption option,
  ) {
    final isSelected = selectedFeedbacks.contains(option.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onFeedbackChanged(option.id, !isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.orange
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Colors.orange.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey,
                    width: 2,
                  ),
                  color: isSelected ? Colors.orange : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),

              // Icon
              Icon(
                option.icon,
                size: 24,
                color: isSelected ? Colors.orange : Colors.grey,
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.orange
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
