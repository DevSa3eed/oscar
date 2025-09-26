import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/duty_person.dart';
import '../../domain/entities/duty_check.dart';
import '../controllers/duty_controller.dart';
import '../widgets/duty_question_flow_widget.dart';
import '../widgets/duty_question_widget.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_navigation.dart';

@RoutePage()
class DutyCheckPage extends ConsumerStatefulWidget {
  final DutyPerson dutyPerson;
  final DutyCheck? existingDutyCheck;

  const DutyCheckPage({
    super.key,
    required this.dutyPerson,
    this.existingDutyCheck,
  });

  @override
  ConsumerState<DutyCheckPage> createState() => _DutyCheckPageState();
}

class _DutyCheckPageState extends ConsumerState<DutyCheckPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DutyQuestionState _currentState = DutyQuestionState.initial;
  bool _isPresent = false;
  bool _isAlertAndVigilant = false;
  bool _isWearingVest = false;
  bool _isLoading = false;
  bool _allQuestionsCompleted = false;

  late final List<DutyQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = [
      DutyQuestion(
        id: 'present',
        question: 'Present at duty post?',
        description: '',
        icon: Icons.person,
        isPositive: true,
        requiredState: DutyQuestionState.initial,
        nextStateYes: DutyQuestionState.present,
        nextStateNo: DutyQuestionState.absent,
      ),
      DutyQuestion(
        id: 'alert_and_vigilant',
        question: 'Alert and vigilant?',
        description: '',
        icon: Icons.visibility,
        isPositive: true,
        requiredState: DutyQuestionState.present,
        nextStateYes: DutyQuestionState.alertAndVigilant,
        nextStateNo: DutyQuestionState.hasIssues,
      ),
      DutyQuestion(
        id: 'wearing_vest',
        question: 'Wearing vest?',
        description: '',
        icon: Icons.checkroom,
        isPositive: true,
        requiredState: DutyQuestionState.alertAndVigilant,
        nextStateYes: null, // End of flow
        nextStateNo: null, // End of flow
      ),
    ];

    // Defer form population to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.existingDutyCheck != null) {
        _populateFormWithExistingData(widget.existingDutyCheck!);
      }
    });
  }

  void _populateFormWithExistingData(DutyCheck existingCheck) {
    print('🔍 Populating form with existing data:');
    print('  - Status: ${existingCheck.status}');
    print('  - Is wearing vest: ${existingCheck.isWearingVest}');
    print('  - Is on phone: ${existingCheck.isOnPhone}');

    setState(() {
      _isPresent = existingCheck.status == AppConstants.presentStatus;
      _isWearingVest = existingCheck.isWearingVest;
      // For editing, infer alert state from existing data
      // If person is present and NOT on phone, they're likely alert and vigilant
      // If person is present but on phone, they're not alert
      _isAlertAndVigilant = _isPresent && !existingCheck.isOnPhone;

      print('  - Computed _isPresent: $_isPresent');
      print('  - Computed _isWearingVest: $_isWearingVest');
      print('  - Computed _isAlertAndVigilant: $_isAlertAndVigilant');
      print('  - Existing isOnPhone: ${existingCheck.isOnPhone}');

      // Set notes
      _notesController.text = existingCheck.notes ?? '';

      // Determine current state based on existing answers
      // Set the state to match where the user left off in the flow
      if (!_isPresent) {
        // Person was marked absent - stay at initial state to allow changing to present
        _currentState = DutyQuestionState.initial;
      } else if (_isPresent && !_isAlertAndVigilant) {
        // Person was present but not alert - stay at present state
        _currentState = DutyQuestionState.present;
      } else if (_isPresent && _isAlertAndVigilant) {
        // Person was present and alert - go to vest question state
        _currentState = DutyQuestionState.alertAndVigilant;
      } else {
        // Default to initial state
        _currentState = DutyQuestionState.initial;
      }

      print('  - Computed _currentState: $_currentState');
    });

    // Don't force completion state - let the question flow widget determine it
    // _allQuestionsCompleted will be set by the onCompletionChanged callback
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppNavigation(
      currentRoute: '/duty-check',
      child: Form(
        key: _formKey,
        child: SafeArea(child: _buildDashboardContent(context)),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Person Info Section
            _buildPersonInfoSection(context, theme),
            const SizedBox(height: 24),

            // Question Flow Section
            _buildQuestionFlowSection(context, theme),
            const SizedBox(height: 24),

            // Notes Section
            _buildNotesSection(context, theme),
            const SizedBox(height: 32),

            // Save Button Section
            _buildSaveButtonSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonInfoSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary,
                child: widget.dutyPerson.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          widget.dutyPerson.photoUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildInitials(),
                        ),
                      )
                    : _buildInitials(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dutyPerson.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dutyPerson.role,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Location Information
          if (widget.dutyPerson.assignedLocationName != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getLocationIcon(
                      widget.dutyPerson.assignedLocationType ?? '',
                    ),
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.dutyPerson.assignedLocationName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.dutyPerson.assignedLocationType != null)
                          Text(
                            _getLocationTypeDisplayName(
                              widget.dutyPerson.assignedLocationType!,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionFlowSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duty Check Questions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DutyQuestionFlowWidget(
              questions: _questions,
              currentState: _currentState,
              initialAnswers: {
                'present': _isPresent,
                'alert_and_vigilant': _isAlertAndVigilant,
                'wearing_vest': _isWearingVest,
              },
              onAnswerChanged: (questionId, answer) {
                setState(() {
                  switch (questionId) {
                    case 'present':
                      _isPresent = answer;
                      if (!answer) {
                        // If not present, reset other answers
                        _isAlertAndVigilant = false;
                        _isWearingVest = false;
                      }
                      break;
                    case 'alert_and_vigilant':
                      _isAlertAndVigilant = answer;
                      if (!answer) {
                        // If not alert and vigilant, reset vest
                        _isWearingVest = false;
                      }
                      break;
                    case 'wearing_vest':
                      _isWearingVest = answer;
                      break;
                  }
                });
              },
              onStateChanged: (newState) {
                setState(() {
                  _currentState = newState;
                });
              },
              onCompletionChanged: (allCompleted) {
                setState(() {
                  _allQuestionsCompleted = allCompleted;
                });
              },
              onEditQuestion: _editQuestion,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Notes (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButtonSection(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isLoading || !_allQuestionsCompleted) ? null : _saveCheck,
        style: ElevatedButton.styleFrom(
          backgroundColor: _allQuestionsCompleted
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          foregroundColor: _allQuestionsCompleted
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _allQuestionsCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _allQuestionsCompleted
                        ? (widget.existingDutyCheck != null
                              ? 'Update Check'
                              : 'Save Check')
                        : 'Answer Questions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = widget.dutyPerson.name
        .split(' ')
        .map((name) => name.isNotEmpty ? name[0].toUpperCase() : '')
        .take(2)
        .join();

    return Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  IconData _getLocationIcon(String locationType) {
    switch (locationType) {
      case 'entrance':
        return Icons.door_front_door;
      case 'playground':
        return Icons.sports_soccer;
      case 'cafeteria':
        return Icons.restaurant;
      case 'library':
        return Icons.local_library;
      case 'office':
        return Icons.business;
      case 'lab':
        return Icons.science;
      case 'classroom':
        return Icons.school;
      default:
        return Icons.location_on;
    }
  }

  String _getLocationTypeDisplayName(String locationType) {
    switch (locationType) {
      case 'entrance':
        return 'Entrance';
      case 'playground':
        return 'Playground';
      case 'cafeteria':
        return 'Cafeteria';
      case 'library':
        return 'Library';
      case 'office':
        return 'Office';
      case 'lab':
        return 'Laboratory';
      case 'classroom':
        return 'Classroom';
      default:
        return 'Location';
    }
  }

  void _editQuestion(String questionId) {
    setState(() {
      switch (questionId) {
        case 'present':
          _currentState = DutyQuestionState.initial;
          break;
        case 'alert_and_vigilant':
          _currentState = DutyQuestionState.present;
          break;
        case 'wearing_vest':
          _currentState = DutyQuestionState.alertAndVigilant;
          break;
      }
    });
  }

  Future<void> _saveCheck() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final isEditing = widget.existingDutyCheck != null;

      print('💾 Saving duty check:');
      print('  - Is editing: $isEditing');
      print('  - _isPresent: $_isPresent');
      print('  - _isWearingVest: $_isWearingVest');
      print('  - _isAlertAndVigilant: $_isAlertAndVigilant');
      print('  - Notes: ${_notesController.text}');

      final dutyCheck = DutyCheck(
        id: isEditing ? widget.existingDutyCheck!.id : const Uuid().v4(),
        dutyPersonId: widget.dutyPerson.id,
        dutyPersonName: widget.dutyPerson.name,
        dutyPersonRole: widget.dutyPerson.role,
        checkDate: isEditing
            ? widget.existingDutyCheck!.checkDate
            : DateTime.now(),
        status: _isPresent
            ? AppConstants.presentStatus
            : AppConstants.absentStatus,
        isOnPhone:
            !_isAlertAndVigilant, // Map alert/vigilant state to isOnPhone field
        isWearingVest: _isWearingVest, // Use actual vest check result
        isOnTime: _isPresent, // Assume on time if present
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        checkedBy: isEditing
            ? widget.existingDutyCheck!.checkedBy
            : 'current_user_id',
        checkedByName: isEditing
            ? widget.existingDutyCheck!.checkedByName
            : 'Current User',
        createdAt: isEditing
            ? widget.existingDutyCheck!.createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('  - Final duty check status: ${dutyCheck.status}');
      print('  - Final duty check isWearingVest: ${dutyCheck.isWearingVest}');
      print(
        '  - Final duty check isOnPhone: ${dutyCheck.isOnPhone} (mapped from alert: $_isAlertAndVigilant)',
      );

      if (isEditing) {
        await ref
            .read(dutyControllerProvider.notifier)
            .updateDutyCheck(dutyCheck);
      } else {
        await ref
            .read(dutyControllerProvider.notifier)
            .saveDutyCheck(dutyCheck);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Duty check updated successfully'
                  : 'Duty check saved successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.router.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${widget.existingDutyCheck != null ? 'update' : 'save'} duty check: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
