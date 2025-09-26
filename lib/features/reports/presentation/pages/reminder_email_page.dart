import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/duty_report.dart';

@RoutePage()
class ReminderEmailPage extends ConsumerStatefulWidget {
  final DutyIssue? issue;

  const ReminderEmailPage({super.key, this.issue});

  @override
  ConsumerState<ReminderEmailPage> createState() => _ReminderEmailPageState();
}

class _ReminderEmailPageState extends ConsumerState<ReminderEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeEmail();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _initializeEmail() {
    if (widget.issue != null) {
      _subjectController.text =
          'Duty Compliance Reminder - ${widget.issue!.dutyPersonName}';
      _bodyController.text = _generateEmailBody(widget.issue!);
    } else {
      _subjectController.text = 'Duty Compliance Reminder';
      _bodyController.text = _generateGeneralEmailBody();
    }
  }

  String _generateEmailBody(DutyIssue issue) {
    final issuesText = issue.issues.join(', ');
    return '''Dear ${issue.dutyPersonName},

During today's duty check, the following issues were noted:
- $issuesText

Please ensure compliance with duty requirements:
- Be present and on time for your assigned duty
- Wear your duty vest at all times
- Avoid using your phone during duty hours
- Follow all duty protocols and guidelines

If you have any questions or concerns, please contact your supervisor immediately.

Thank you for your attention to this matter.

Best regards,
HOD''';
  }

  String _generateGeneralEmailBody() {
    return '''Dear Team,

This is a general reminder about duty compliance requirements:

- Be present and on time for your assigned duties
- Wear your duty vest at all times
- Avoid using your phone during duty hours
- Follow all duty protocols and guidelines

Please ensure you are meeting these standards consistently.

If you have any questions or concerns, please contact your supervisor.

Best regards,
HOD''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Reminder Email'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _sendEmail,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipient Info
                if (widget.issue != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.orange.withAlpha(10),
                            child: Icon(
                              Icons.person,
                              color: Colors.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.issue!.dutyPersonName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.issue!.dutyPersonRole,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                ),
                                Text(
                                  widget.issue!.dutyPersonEmail,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Email Form
                const SizedBox(height: 16),

                // SCROLL REQUIRED: Form content can overflow when keyboard is shown
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Field
                        TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email subject';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Body Field
                        TextFormField(
                          controller: _bodyController,
                          maxLines: 12,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email message';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Send Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _sendEmail,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              _isLoading ? 'Sending...' : 'Send Email',
                            ),
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
      ),
    );
  }

  Future<void> _sendEmail() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate email sending
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.issue != null
                  ? 'Reminder email sent to ${widget.issue!.dutyPersonName}'
                  : 'Reminder email sent to all duty persons',
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
            content: Text('Failed to send email: $e'),
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
