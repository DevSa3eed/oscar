import 'package:flutter/material.dart';
import 'duty_question_widget.dart';

class DutyQuestionFlowWidget extends StatefulWidget {
  final List<DutyQuestion> questions;
  final Map<String, bool> initialAnswers;
  final DutyQuestionState currentState;
  final Function(String questionId, bool answer) onAnswerChanged;
  final Function(DutyQuestionState newState) onStateChanged;
  final Function(bool allCompleted) onCompletionChanged;
  final Function(String questionId)? onEditQuestion;

  const DutyQuestionFlowWidget({
    super.key,
    required this.questions,
    required this.initialAnswers,
    required this.currentState,
    required this.onAnswerChanged,
    required this.onStateChanged,
    required this.onCompletionChanged,
    this.onEditQuestion,
  });

  @override
  State<DutyQuestionFlowWidget> createState() => _DutyQuestionFlowWidgetState();
}

class _DutyQuestionFlowWidgetState extends State<DutyQuestionFlowWidget> {
  late Map<String, bool> _answers;

  @override
  void initState() {
    super.initState();
    // Only include answers that are actually answered (true), not false values
    _answers = Map<String, bool>.fromEntries(
      widget.initialAnswers.entries.where((entry) => entry.value == true),
    );
    // Defer the completion update to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCompletion();
    });
  }

  void _updateCompletion() {
    // Check completion based on current state
    bool isCompleted = false;

    switch (widget.currentState) {
      case DutyQuestionState.initial:
        // Present question answered (true or false, but not null)
        isCompleted = _answers.containsKey('present');
        break;
      case DutyQuestionState.absent:
        // Person absent - can submit
        isCompleted = true;
        break;
      case DutyQuestionState.present:
        // Alert question answered (true or false, but not null)
        isCompleted = _answers.containsKey('alert_and_vigilant');
        break;
      case DutyQuestionState.hasIssues:
        // Person not alert - can submit
        isCompleted = true;
        break;
      case DutyQuestionState.alertAndVigilant:
        // Vest question answered (true or false, but not null)
        isCompleted = _answers.containsKey('wearing_vest');
        break;
    }

    widget.onCompletionChanged(isCompleted);
  }

  void _onAnswer(String questionId, bool answer) {
    setState(() {
      _answers[questionId] = answer;
    });

    widget.onAnswerChanged(questionId, answer);

    // Find the question and transition to next state
    final question = widget.questions.firstWhere((q) => q.id == questionId);
    DutyQuestionState? nextState;

    if (answer) {
      nextState = question.nextStateYes;
    } else {
      nextState = question.nextStateNo;
    }

    if (nextState != null) {
      widget.onStateChanged(nextState);
    } else {
      // If no next state (final question), stay in current state but mark as completed
      // This will make the question minimize since it's answered but not current
    }

    _updateCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.questions.map((question) {
        final isCurrentQuestion = question.requiredState == widget.currentState;
        final isAnswered = _answers.containsKey(question.id);
        final answerValue = _answers[question.id];

        // Show question if it's the current question OR if it's been answered (minimized)
        // For final questions, if answered, show as minimized even if it's the current question
        final isVisible = isCurrentQuestion || isAnswered;
        final shouldMinimize =
            isAnswered &&
            (!isCurrentQuestion ||
                (question.nextStateYes == null &&
                    question.nextStateNo == null));

        return DutyQuestionWidget(
          question: question,
          isVisible: isVisible,
          isAnswered: isAnswered,
          answerValue: answerValue,
          isCurrentQuestion: isCurrentQuestion,
          shouldMinimize: shouldMinimize,
          onAnswer: _onAnswer,
          onEdit: widget.onEditQuestion,
        );
      }).toList(),
    );
  }
}
