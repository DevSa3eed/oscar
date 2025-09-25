import 'package:flutter/material.dart';

enum DutyCheckState { initial, present, absent, alertAndVigilant, hasIssues }

class DutyChecklistItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isRequired;
  final bool
  isPositive; // true for positive checks (Present), false for negative checks (On phone)
  final DutyCheckState requiredState; // When this item becomes visible
  final DutyCheckState nextState; // What state to transition to

  const DutyChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isRequired = true,
    this.isPositive = true,
    required this.requiredState,
    required this.nextState,
  });
}

class DutyChecklistWidget extends StatefulWidget {
  final List<DutyChecklistItem> items;
  final Map<String, bool> initialValues;
  final DutyCheckState currentState;
  final Function(String itemId, bool value) onItemChanged;
  final Function(bool allCompleted) onCompletionChanged;
  final Function(DutyCheckState newState) onStateChanged;

  const DutyChecklistWidget({
    super.key,
    required this.items,
    required this.initialValues,
    required this.currentState,
    required this.onItemChanged,
    required this.onCompletionChanged,
    required this.onStateChanged,
  });

  @override
  State<DutyChecklistWidget> createState() => _DutyChecklistWidgetState();
}

class _DutyChecklistWidgetState extends State<DutyChecklistWidget> {
  late Map<String, bool> _values;

  @override
  void initState() {
    super.initState();
    _values = Map<String, bool>.from(widget.initialValues);
    // Defer the completion update to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCompletion();
    });
  }

  void _updateCompletion() {
    // Only check completion for visible items
    final visibleItems = widget.items
        .where(
          (item) =>
              item.requiredState == widget.currentState ||
              (_values[item.id] == true),
        )
        .toList();

    final allCompleted = visibleItems.every((item) => _values[item.id] == true);
    widget.onCompletionChanged(allCompleted);
  }

  void _onItemChanged(String itemId, bool value) {
    setState(() {
      _values[itemId] = value;
    });
    widget.onItemChanged(itemId, value);

    // Find the item and handle state transitions
    final item = widget.items.firstWhere((item) => item.id == itemId);
    if (value) {
      // Item checked - transition to next state
      widget.onStateChanged(item.nextState);
    } else {
      // Item unchecked - transition back to appropriate state
      if (itemId == 'present' || itemId == 'absent') {
        widget.onStateChanged(DutyCheckState.initial);
      } else if (itemId == 'alert_and_vigilant' || itemId == 'has_issues') {
        widget.onStateChanged(DutyCheckState.present);
      }
    }

    _updateCompletion();
  }

  @override
  Widget build(BuildContext context) {
    // Filter items based on current state and checked status
    final visibleItems = widget.items
        .where(
          (item) =>
              item.requiredState == widget.currentState ||
              (_values[item.id] == true),
        )
        .toList();

    return Column(
      children: visibleItems.map((item) {
        final isChecked = _values[item.id] ?? false;
        final isPositive = item.isPositive;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isChecked
                    ? (isPositive ? Colors.green : Colors.red)
                    : Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => _onItemChanged(item.id, !isChecked),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: isChecked
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (isPositive ? Colors.green : Colors.red).withValues(
                              alpha: 0.05,
                            ),
                            (isPositive ? Colors.green : Colors.red).withValues(
                              alpha: 0.02,
                            ),
                          ],
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    // Checkbox
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isChecked
                            ? (isPositive ? Colors.green : Colors.red)
                            : Colors.transparent,
                        border: Border.all(
                          color: isChecked
                              ? (isPositive ? Colors.green : Colors.red)
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: isChecked
                          ? Icon(
                              isPositive ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isChecked
                            ? (isPositive ? Colors.green : Colors.red)
                                  .withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: isChecked
                            ? (isPositive ? Colors.green : Colors.red)
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isChecked
                                      ? (isPositive ? Colors.green : Colors.red)
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
