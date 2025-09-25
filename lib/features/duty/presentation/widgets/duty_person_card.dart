import 'package:flutter/material.dart';
import '../../domain/entities/duty_person.dart';
import '../../domain/entities/duty_check.dart';
import '../../../../core/constants/app_constants.dart';

class DutyPersonCard extends StatelessWidget {
  final DutyPerson dutyPerson;
  final DutyCheck dutyCheck;
  final VoidCallback onTap;

  const DutyPersonCard({
    super.key,
    required this.dutyPerson,
    required this.dutyCheck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasIssues = dutyCheck.isOnPhone || !dutyCheck.isWearingVest;
    final isPresent = dutyCheck.status == AppConstants.presentStatus;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: _getStatusColor(
        context,
        isPresent,
        hasIssues,
      ).withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                _getStatusColor(
                  context,
                  isPresent,
                  hasIssues,
                ).withValues(alpha: 0.02),
              ],
            ),
            border: Border.all(
              color: _getStatusColor(
                context,
                isPresent,
                hasIssues,
              ).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Enhanced Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(
                        context,
                        isPresent,
                        hasIssues,
                      ).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: _getStatusColor(
                    context,
                    isPresent,
                    hasIssues,
                  ),
                  child: dutyPerson.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            dutyPerson.photoUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildInitials(),
                          ),
                        )
                      : _buildInitials(),
                ),
              ),
              const SizedBox(width: 16),

              // Enhanced Person Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dutyPerson.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          context,
                          isPresent,
                          hasIssues,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dutyPerson.role,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(context, isPresent, hasIssues),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildEnhancedStatusChip(
                          context,
                          isPresent ? 'Present' : 'Absent',
                          isPresent ? Colors.green : Colors.red,
                        ),
                        if (hasIssues)
                          _buildEnhancedStatusChip(
                            context,
                            'Issues',
                            Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Enhanced Status Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    context,
                    isPresent,
                    hasIssues,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _getStatusColor(
                      context,
                      isPresent,
                      hasIssues,
                    ).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getStatusIcon(isPresent, hasIssues),
                  color: _getStatusColor(context, isPresent, hasIssues),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = dutyPerson.name
        .split(' ')
        .map((name) => name.isNotEmpty ? name[0].toUpperCase() : '')
        .take(2)
        .join();

    return Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildEnhancedStatusChip(
    BuildContext context,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.15)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getChipIcon(label), color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getChipIcon(String label) {
    switch (label) {
      case 'Present':
        return Icons.check_circle;
      case 'Absent':
        return Icons.cancel;
      case 'Issues':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(BuildContext context, bool isPresent, bool hasIssues) {
    if (!isPresent) return Colors.red;
    if (hasIssues) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(bool isPresent, bool hasIssues) {
    if (!isPresent) return Icons.cancel;
    if (hasIssues) return Icons.warning;
    return Icons.check_circle;
  }
}
