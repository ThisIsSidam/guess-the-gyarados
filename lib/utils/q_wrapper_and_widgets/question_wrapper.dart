import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/provider/steps_provider.dart';
import 'package:guessthegyarados/utils/q_wrapper_and_widgets/bottom_sheet_methods.dart';

class QuestionWrapper extends ConsumerStatefulWidget {
  final String question;
  final String answer;
  final Widget child;
  final Widget? aliasWidget;
  final bool answerIsBoolean;
  final List<String>? options;
  final bool showTextFieldWithOptions;

  const QuestionWrapper({
    super.key,
    required this.question,
    required this.answer,
    required this.child,
    this.aliasWidget,
    this.answerIsBoolean = false,
    this.options,
    this.showTextFieldWithOptions = false,
  });

  @override
  ConsumerState<QuestionWrapper> createState() => _QuestionWrapperState();
}

class _QuestionWrapperState extends ConsumerState<QuestionWrapper> {
  bool isGuessedCorrectly = false;
  

  late int stepsCount = ref.read(counterProvider);
  late CounterNotifier stepsCountNotifier = ref.read(counterProvider.notifier); 

  void onTap(bool answerIsCorrect)
  {
    setState(() {
      stepsCountNotifier.increment();
      if (answerIsCorrect)
      {
        isGuessedCorrectly = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showInputDialog,
      child: widget.aliasWidget == null
      ? Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: getFinalChild(),
        )
      : getFinalChild(),
    );
  }

  Widget getFinalChild() {
    if (isGuessedCorrectly && widget.aliasWidget == null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: widget.child),
            Flexible(
              child: Text(
                " | ${widget.answer}",
                style: Theme.of(context).textTheme.titleSmall,
              )
            ),
          ],
        ),
      );
    } else if (isGuessedCorrectly && widget.aliasWidget != null) {
      return widget.child;
    } else if (!isGuessedCorrectly && widget.aliasWidget != null) {
      return widget.aliasWidget!;
    } else {
      return widget.child;
    }
  }

  void _showInputDialog() {
    if (isGuessedCorrectly) return;

    if (widget.answerIsBoolean) 
    {
      _showBooleanAnswerDialog(context);
    } 
    else if (widget.options != null && widget.showTextFieldWithOptions) 
    {
      showTextFieldWithOptionsBottomSheet(
        context, 
        widget.question, 
        widget.answer, 
        widget.options!,
        isAnswerCorrect: onTap
      );
    } 
    else if (widget.options != null) 
    {
      showOptionsBottomSheet(
        context, 
        widget.question, 
        widget.answer, 
        widget.options!,
        isAnswerCorrect: onTap
      );
    } 
    else 
    {
      showTextInputBottomSheet(
        context, 
        widget.question, 
        widget.answer, 
        isAnswerCorrect: onTap
      );
    }
  }

  void _showBooleanAnswerDialog(BuildContext context) {
    setState(() {
      stepsCountNotifier.increment();
      isGuessedCorrectly = true;
    });
  }
}