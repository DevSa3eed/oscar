import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/duty_controller.dart';
import '../../domain/entities/duty_person.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/duty_assignment.dart';
import '../../../../core/navigation/app_navigation.dart';

@RoutePage()
class DutyAssignmentPage extends ConsumerStatefulWidget {
  const DutyAssignmentPage({super.key});

  @override
  ConsumerState<DutyAssignmentPage> createState() => _DutyAssignmentPageState();
}

class _DutyAssignmentPageState extends ConsumerState<DutyAssignmentPage> {
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final dutyState = ref.watch(dutyControllerProvider);

    // Initialize data on first build
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isInitialized) {
          _isInitialized = true;
          ref.read(dutyControllerProvider.notifier).loadDutyData();
          ref.read(dutyControllerProvider.notifier).loadLocations();
          ref.read(dutyControllerProvider.notifier).loadDutyAssignments();
        }
      });
    }

    // Use all duty persons and locations
    final filteredDutyPersons = dutyState.dutyPersons;
    final filteredLocations = dutyState.locations;

    return AppNavigation(
      currentRoute: '/duty-assignment',
      child: SafeArea(
        child: dutyState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : dutyState.errorMessage != null
            ? _buildErrorState(context, dutyState.errorMessage!)
            : _buildDashboardContent(
                context,
                dutyState,
                filteredDutyPersons,
                filteredLocations,
              ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(dutyControllerProvider.notifier).loadDutyData();
                ref.read(dutyControllerProvider.notifier).loadLocations();
                ref.read(dutyControllerProvider.notifier).loadDutyAssignments();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    dutyState,
    List<DutyPerson> filteredDutyPersons,
    List<Location> filteredLocations,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards Row
            _buildStatsRow(context, theme, dutyState),
            const SizedBox(height: 24),

            // Personnel Section
            _buildPersonnelSection(
              context,
              theme,
              filteredDutyPersons,
              filteredLocations,
              dutyState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ThemeData theme, dutyState) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Personnel',
            dutyState.dutyPersons.length.toString(),
            Icons.people,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Assigned',
            _getAssignedCount(dutyState.dutyPersons).toString(),
            Icons.assignment_ind,
            theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Unassigned',
            _getUnassignedCount(dutyState.dutyPersons).toString(),
            Icons.person_off,
            theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonnelSection(
    BuildContext context,
    ThemeData theme,
    List<DutyPerson> filteredDutyPersons,
    List<Location> filteredLocations,
    dutyState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personnel Assignment',
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
          child: filteredDutyPersons.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredDutyPersons.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final dutyPerson = filteredDutyPersons[index];
                    final assignment = _getAssignmentForPerson(
                      dutyPerson.id,
                      dutyState.dutyAssignments,
                    );
                    return _buildDutyPersonCard(
                      context,
                      dutyPerson,
                      assignment,
                      filteredLocations,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.person_add,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Personnel Added Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first team member to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddPersonDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Personnel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDutyPersonCard(
    BuildContext context,
    DutyPerson dutyPerson,
    DutyAssignment? assignment,
    List<Location> locations,
  ) {
    final theme = Theme.of(context);
    final isAssigned = assignment != null;
    final statusColor = isAssigned
        ? theme.colorScheme.tertiary
        : theme.colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    isAssigned ? Icons.assignment_ind : Icons.person_off,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dutyPerson.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dutyPerson.role,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      Text(
                        dutyPerson.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isAssigned ? 'Assigned' : 'Unassigned',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (assignment != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getLocationIcon(assignment.locationType),
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          assignment.locationName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLocationTypeDisplayName(assignment.locationType),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    if (assignment.startTime != null &&
                        assignment.endTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('HH:mm').format(assignment.startTime!)} - ${DateFormat('HH:mm').format(assignment.endTime!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                    if (assignment.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        assignment.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (assignment != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _removeAssignment(assignment.id),
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Remove Assignment'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showAssignmentDialog(dutyPerson, locations),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Assign Location'),
                    ),
                  ),
                if (assignment != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAssignmentDialog(
                        dutyPerson,
                        locations,
                        assignment,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getAssignedCount(List<DutyPerson> dutyPersons) {
    return dutyPersons
        .where((person) => person.assignedLocationName != null)
        .length;
  }

  int _getUnassignedCount(List<DutyPerson> dutyPersons) {
    return dutyPersons
        .where((person) => person.assignedLocationName == null)
        .length;
  }

  DutyAssignment? _getAssignmentForPerson(
    String dutyPersonId,
    List<DutyAssignment> assignments,
  ) {
    try {
      return assignments.firstWhere(
        (assignment) => assignment.dutyPersonId == dutyPersonId,
      );
    } catch (e) {
      return null;
    }
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

  void _showAssignmentDialog(
    DutyPerson dutyPerson,
    List<Location> locations, [
    DutyAssignment? existingAssignment,
  ]) {
    Location? selectedLocation;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    final notesController = TextEditingController(
      text: existingAssignment?.notes ?? '',
    );

    if (existingAssignment != null) {
      selectedLocation = locations.firstWhere(
        (loc) => loc.id == existingAssignment.locationId,
        orElse: () => locations.first,
      );
      if (existingAssignment.startTime != null) {
        startTime = TimeOfDay.fromDateTime(existingAssignment.startTime!);
      }
      if (existingAssignment.endTime != null) {
        endTime = TimeOfDay.fromDateTime(existingAssignment.endTime!);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existingAssignment != null ? 'Edit Assignment' : 'Assign Location',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location Selection
                DropdownButtonFormField<Location>(
                  initialValue: selectedLocation,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  items: locations.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Row(
                        children: [
                          Icon(_getLocationIcon(location.type), size: 16),
                          const SizedBox(width: 8),
                          Text(location.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedLocation = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Start Time
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    startTime != null
                        ? 'Start: ${startTime!.format(context)}'
                        : 'Start Time',
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime:
                          startTime ?? const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (time != null) {
                      setDialogState(() {
                        startTime = time;
                      });
                    }
                  },
                ),
                // End Time
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    endTime != null
                        ? 'End: ${endTime!.format(context)}'
                        : 'End Time',
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime:
                          endTime ?? const TimeOfDay(hour: 17, minute: 0),
                    );
                    if (time != null) {
                      setDialogState(() {
                        endTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedLocation != null
                  ? () {
                      if (existingAssignment != null) {
                        // Remove existing assignment first
                        _removeAssignment(existingAssignment.id);
                      }
                      _assignDutyPerson(
                        dutyPerson,
                        selectedLocation!,
                        startTime,
                        endTime,
                        notesController.text.trim(),
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(existingAssignment != null ? 'Update' : 'Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _assignDutyPerson(
    DutyPerson dutyPerson,
    Location location,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String notes,
  ) {
    final now = DateTime.now();
    final startDateTime = startTime != null
        ? DateTime(
            now.year,
            now.month,
            now.day,
            startTime.hour,
            startTime.minute,
          )
        : null;
    final endDateTime = endTime != null
        ? DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute)
        : null;

    ref
        .read(dutyControllerProvider.notifier)
        .assignDutyPerson(
          dutyPersonId: dutyPerson.id,
          locationId: location.id,
          locationName: location.name,
          locationType: location.type,
          startTime: startDateTime,
          endTime: endDateTime,
          notes: notes.isEmpty ? null : notes,
        );
  }

  void _removeAssignment(String assignmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assignment'),
        content: const Text('Are you sure you want to remove this assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(dutyControllerProvider.notifier)
                  .removeDutyAssignment(assignmentId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Personnel'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Role Field
                TextFormField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Role/Position',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                    hintText: 'e.g., Security Guard, Supervisor',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email Field
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                ref
                    .read(dutyControllerProvider.notifier)
                    .addDutyPerson(
                      name: nameController.text.trim(),
                      role: roleController.text.trim(),
                      email: emailController.text.trim(),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Personnel added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add Personnel'),
          ),
        ],
      ),
    );
  }
}
