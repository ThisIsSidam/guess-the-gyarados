import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guessthegyarados/core/extensions/string_extensions.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';

/// The single, shared answer surface for every guessable clue (and the final
/// Pokemon-name guess), shown as the content of a [showModalBottomSheet] —
/// see `clue_answer_sheet.dart`.
///
/// Fewer than 20 options are shown directly as a pickable grid. More than
/// that (the ~1025-name Pokedex search) switches to a search field with a
/// live-filtered, capped result list.
class InlineAnswerPanel extends StatefulWidget {
  const InlineAnswerPanel({
    super.key,
    required this.question,
    required this.options,
    required this.onSelect,
    required this.onClose,
    this.coloredOptions = false,
    this.accentColor = GameColors.primary,
  });

  final String question;
  final List<String> options;
  final bool coloredOptions;
  final Color accentColor;
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  @override
  State<InlineAnswerPanel> createState() => _InlineAnswerPanelState();
}

class _InlineAnswerPanelState extends State<InlineAnswerPanel> {
  late List<String> _filtered = _initialOptions;
  final _searchController = TextEditingController();

  bool get _showSearchField => widget.options.length > 20;

  List<String> get _initialOptions => _showSearchField ? [] : widget.options;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filtered = [];
        return;
      }
      _filtered = widget.options
          .where((option) => option.toLowerCase().contains(value.toLowerCase()))
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (_filtered.length > 10) _filtered = _filtered.sublist(0, 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.question,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: GameColors.textOnLight),
                ),
              ),
              InkWell(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: GameColors.textMuted, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_showSearchField)
            TextField(
              autofocus: true,
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: GameColors.textOnLight),
              decoration: const InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search, color: GameColors.textMuted),
              ),
            ),
          if (_showSearchField) const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_showSearchField ? _filtered : widget.options)
                    .map((option) => _OptionPill(
                          label: option,
                          color: widget.coloredOptions ? getColorFromString(option) : GameColors.surfaceRaised,
                          textColor: widget.coloredOptions ? GameColors.textOnDark : GameColors.textOnLight,
                          onTap: () => widget.onSelect(option),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onLight = textColor == GameColors.textOnLight;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 56, minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onLight ? Colors.black.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (getIconPathForType(label) case final path?) ...[
              SvgPicture.asset(
                path,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label.capitalize,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
