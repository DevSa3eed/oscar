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
    // Include all initial answers (both true and false) to properly handle editing mode
    _answers = Map<String, bool>.from(widget.initialAnswers);
    print('🔄 DutyQuestionFlowWidget initState:');
    print('  - Initial answers: $_answers');
    print('  - Current state: ${widget.currentState}');
    // Defer the completion update to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCompletion();
    });
  }

  @override
  void didUpdateWidget(DutyQuestionFlowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update answers if initial answers have changed (important for editing mode)
    if (oldWidget.initialAnswers != widget.initialAnswers) {
      _answers = Map<String, bool>.from(widget.initialAnswers);
      // Defer completion update to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateCompletion();
      });
    }
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
      case DutyQuestionState.completed:
        // All questions completed
        isCompleted = true;
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
      // If no next state (final question), transition to completed state
      // This will cause the question to be minimized
      widget.onStateChanged(DutyQuestionState.completed);
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
        final isFinalQuestion =
            question.nextStateYes == null && question.nextStateNo == null;

        print('📋 Question ${question.id}:');
        print('  - Required state: ${question.requiredState}');
        print('  - Current state: ${widget.currentState}');
        print('  - Is current: $isCurrentQuestion');
        print('  - Is answered: $isAnswered');
        print('  - Answer value: $answerValue');
        print('  - Next state yes: ${question.nextStateYes}');
        print('  - Next state no: ${question.nextStateNo}');
        print('  - Is final question: $isFinalQuestion');

        // Show question if it's the current question OR if it's been answered (minimized)
        // For final questions, if answered, show as minimized even if it's the current question
        final isVisible = isCurrentQuestion || isAnswered;

        // Minimize questions if they're answered and not the current question
        // This applies to both regular and final questions
        final shouldMinimize = isAnswered && !isCurrentQuestion;

        print('  - Should minimize: $shouldMinimize');

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
