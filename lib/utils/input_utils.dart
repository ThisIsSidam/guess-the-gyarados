import 'package:flutter/material.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

void showTextInputBottomSheet(
  BuildContext context, 
  String question, 
  String answer, 
  {required Function(bool) isAnswerCorrect}
) {
  final textController = TextEditingController();
  showBottomSheet(
    context: context,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(question, style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                autofocus: true,
                controller: textController,
                onSubmitted: (value) {
                  final answerCorrect = value.toLowerCase() == answer.toLowerCase();

                  isAnswerCorrect(answerCorrect);
                  if (answerCorrect) 
                  {
                    Navigator.pop(context);
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showOptionsBottomSheet(
  BuildContext context, 
  String question, 
  String answer, 
  List<String> options, 
  {required Function(bool) isAnswerCorrect}
) {
  showBottomSheet(
    context: context,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(question, style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    children: options
                        .map(
                          (option) => GestureDetector(
                            onTap: () {
                              final answerCorrect = option.toLowerCase() == answer.toLowerCase();

                              isAnswerCorrect(answerCorrect);
                              if (answerCorrect) 
                              {
                                Navigator.pop(context);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                alignment: Alignment.center,
                                width: option.length < 3 ? 50 : option.length * 20,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: getColorFromString(option),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(option),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showTextFieldWithOptionsBottomSheet(
  BuildContext context, 
  String question, 
  String answer, 
  List<String> options, 
  {required Function(bool) isAnswerCorrect}
) {
  final textController = TextEditingController();
  List<String> filteredOptions = [];

  
  showBottomSheet(
    context: context,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(question, style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    autofocus: true,
                    controller: textController,
                    autofillHints: filteredOptions,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        filteredOptions = options
                            .where((option) => option.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                        filteredOptions.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                        if (filteredOptions.length > 10) {
                          filteredOptions = filteredOptions.sublist(0, 10);
                        }
                      } else {
                        filteredOptions.clear();
                      }
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search...',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        children: filteredOptions
                            .map(
                              (option) => GestureDetector(
                                onTap: () {
                                  final answerCorrect = option.toLowerCase() == answer.toLowerCase();

                                  isAnswerCorrect(answerCorrect);
                                  if (answerCorrect) 
                                  {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: option.length < 6 
                                    ? option.length * 20 
                                    : option.length *15,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(option),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}