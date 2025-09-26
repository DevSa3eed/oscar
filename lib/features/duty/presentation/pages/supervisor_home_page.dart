import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/duty_controller.dart';
import '../widgets/duty_person_card.dart';
import '../../domain/entities/duty_check.dart';
import '../../domain/entities/duty_person.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/navigation/app_navigation.dart';

@RoutePage()
class SupervisorHomePage extends ConsumerStatefulWidget {
  const SupervisorHomePage({super.key});

  @override
  ConsumerState<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends ConsumerState<SupervisorHomePage> {
  bool _isInitialized = false;
  final String _selectedLocationFilter = 'All';
  final String _selectedLocationType = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page
    if (_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(dutyControllerProvider.notifier).loadDutyData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dutyState = ref.watch(dutyControllerProvider);

    // Initialize duty controller on first build only
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isInitialized) {
          _isInitialized = true;
          ref.read(dutyControllerProvider.notifier).loadDutyData();
        }
      });
    }

    // Filter and group duty persons by location
    final filteredDutyPersons = _filterDutyPersons(dutyState.dutyPersons);
    final groupedDutyPersons = _groupDutyPersonsByLocation(filteredDutyPersons);

    return AppNavigation(
      currentRoute: '/supervisor-home',
      child: SafeArea(
        child: dutyState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : dutyState.errorMessage != null
            ? _buildErrorState(context, dutyState.errorMessage!)
            : _buildDashboardContent(
                context,
                dutyState,
                filteredDutyPersons,
                groupedDutyPersons,
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
              onPressed: () =>
                  ref.read(dutyControllerProvider.notifier).loadDutyData(),
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
    List<Map<String, dynamic>> groupedDutyPersons,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            _buildDateHeader(context, theme),
            const SizedBox(height: 24),

            // Statistics Cards Row
            _buildStatsRow(context, theme, dutyState),
            const SizedBox(height: 24),

            // Personnel Section
            _buildPersonnelSection(
              context,
              theme,
              filteredDutyPersons,
              groupedDutyPersons,
              dutyState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
            dutyState.totalPersons.toString(),
            Icons.people,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Present',
            dutyState.presentCount.toString(),
            Icons.check_circle,
            theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Issues',
            dutyState.issuesCount.toString(),
            Icons.warning,
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
    List<Map<String, dynamic>> groupedDutyPersons,
    dutyState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personnel by Location',
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
              ? _buildNoPersonnelState(context, theme)
              : Column(
                  children: groupedDutyPersons.map((locationGroup) {
                    return _buildLocationGroup(
                      context,
                      locationGroup,
                      dutyState.dutyChecks,
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildNoPersonnelState(BuildContext context, ThemeData theme) {
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
                Icons.assignment_ind,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Personnel Found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your filters or add personnel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<DutyPerson> _filterDutyPersons(List<DutyPerson> dutyPersons) {
    if (_selectedLocationFilter == 'All' && _selectedLocationType == 'All') {
      return dutyPersons;
    }

    return dutyPersons.where((person) {
      final locationMatch =
          _selectedLocationFilter == 'All' ||
          person.assignedLocationName == _selectedLocationFilter;
      final typeMatch =
          _selectedLocationType == 'All' ||
          person.assignedLocationType == _selectedLocationType;
      return locationMatch && typeMatch;
    }).toList();
  }

  List<Map<String, dynamic>> _groupDutyPersonsByLocation(
    List<DutyPerson> dutyPersons,
  ) {
    final Map<String, List<DutyPerson>> grouped = {};

    for (final person in dutyPersons) {
      final locationKey = person.assignedLocationName ?? 'Unassigned';
      if (!grouped.containsKey(locationKey)) {
        grouped[locationKey] = [];
      }
      grouped[locationKey]!.add(person);
    }

    return grouped.entries
        .map(
          (entry) => {
            'locationName': entry.key,
            'locationType': entry.value.first.assignedLocationType ?? 'unknown',
            'dutyPersons': entry.value,
          },
        )
        .toList();
  }

  Widget _buildLocationGroup(
    BuildContext context,
    Map<String, dynamic> locationGroup,
    List<DutyCheck> dutyChecks,
  ) {
    final String locationName = locationGroup['locationName'];
    final String locationType = locationGroup['locationType'];
    final List<DutyPerson> dutyPersons = List<DutyPerson>.from(
      locationGroup['dutyPersons'],
    );
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    _getLocationIcon(locationType),
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLocationTypeDisplayName(locationType),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${dutyPersons.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Personnel List
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: dutyPersons.map((dutyPerson) {
                // Find existing duty check for this person
                final existingCheck =
                    dutyChecks
                        .where((check) => check.dutyPersonId == dutyPerson.id)
                        .isNotEmpty
                    ? dutyChecks.firstWhere(
                        (check) => check.dutyPersonId == dutyPerson.id,
                      )
                    : null;

                // Create default absent check only if no check exists
                final dutyCheck =
                    existingCheck ??
                    DutyCheck(
                      id: '',
                      dutyPersonId: dutyPerson.id,
                      dutyPersonName: dutyPerson.name,
                      dutyPersonRole: dutyPerson.role,
                      checkDate: DateTime.now(),
                      status: 'absent',
                      isOnPhone: false,
                      isWearingVest: false,
                      checkedBy: '',
                      checkedByName: '',
                    );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DutyPersonCard(
                    dutyPerson: dutyPerson,
                    dutyCheck: dutyCheck,
                    onTap: () => context.router.push(
                      DutyCheckRoute(dutyPerson: dutyPerson),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
}
