import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/provider/steps_provider.dart';
import 'package:guessthegyarados/utils/q_wrapper_and_widgets/bottom_sheet_methods.dart';

// A Widget which is wrapped with a question. It shows the child widget normally. 
// Upon tap, it opens a bottomSheet (Directly shows answer if answerIsBoolean).
// User can give answer in the bottomSheet. The type of bottomSheet opened may vary 
// according to the passed arguments.
class QuestionWrapper extends ConsumerStatefulWidget {
  final String question;
  final String answer;
  final Widget child;
  final Widget? aliasWidget;
  final bool answerIsBoolean;
  final List<String>? options;
  final bool showTextFieldWithOptions;
  final bool coloredOptions;
  final Color defaultColor;

  const QuestionWrapper({
    super.key,
    required this.question,
    required this.answer,
    required this.child,
    this.aliasWidget,
    this.answerIsBoolean = false,
    this.options,
    this.showTextFieldWithOptions = false,
    this.coloredOptions = false,
    this.defaultColor = Colors.black
  });

  @override
  ConsumerState<QuestionWrapper> createState() => _QuestionWrapperState();
}

class _QuestionWrapperState extends ConsumerState<QuestionWrapper> {
  bool isGuessedCorrectly = false;
  

  late int stepsCount = ref.read(counterProvider);
  late CounterNotifier stepsCountNotifier = ref.read(counterProvider.notifier); 

  void bottomSheetOnTap(bool answerIsCorrect)
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
      ? Chip(
          color: MaterialStatePropertyAll(widget.defaultColor),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          label: getFinalChild(),
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
    if (isGuessedCorrectly) return; // Dialog not shown if already answered.

    if (widget.answerIsBoolean) // Answer directly shown if answerIsBoolean.
    {
      _showBooleanAnswerDialog(context);
    } 
    // Text Field is provided and user can search the options. Options are shown directly
    // if there are under 20.
    else if (widget.options != null) 
    {
      showTextFieldWithOptionsBottomSheet(
        context, 
        widget.question, 
        widget.answer, 
        widget.options!,
        coloredOptions: widget.coloredOptions,
        isAnswerCorrect: bottomSheetOnTap
      );
    }  
    // User has to search the exact answer.
    else 
    { 
      showTextInputBottomSheet(
        context, 
        widget.question, 
        widget.answer, 
        isAnswerCorrect: bottomSheetOnTap
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