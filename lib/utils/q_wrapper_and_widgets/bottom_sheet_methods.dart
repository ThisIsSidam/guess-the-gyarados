import 'package:flutter/material.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

// User gets a search bar to search the answer in the bottom sheet.
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

// User gets a bottom sheet. If not many options, the options would be shown directly. 
// If lots of options, then none would be shown and a search would be provided which 
// would show a number of results for the search query.
void showTextFieldWithOptionsBottomSheet(
  BuildContext context, 
  String question, 
  String answer, 
  List<String> options, 
  {
    bool coloredOptions = false,
    required Function(bool) isAnswerCorrect
  }
) {
  final textController = TextEditingController();
  final optionsLen = options.length;
  List<String> filteredOptions = [];
  bool showSearchBar = optionsLen > 20;

  if (!showSearchBar)
  {
    filteredOptions = options; // Since in this case, we won't be showing the search bar.
  }
  
  showBottomSheet(
    context: context,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: showSearchBar
        ? 0.9
        : 0.5,
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
                  if (showSearchBar) // Don't show search bar if not many options
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
                                  child: getContainerForOption(option, coloredOptions),
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

Widget getContainerForOption(String option, bool colorTheContainer) {
  final optionLen = option.length;
  return Container(
    alignment: Alignment.center,
    width: optionLen < 6 
    ? optionLen <= 3
      ? 80
      : optionLen * 20
    : optionLen > 10
      ? optionLen * 10
      : optionLen * 15,
    height: 80,
    decoration: BoxDecoration(
      color: colorTheContainer ? getColorFromString(option) : Colors.black12,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(option),
  );
}