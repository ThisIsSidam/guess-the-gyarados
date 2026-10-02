import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guessthegyarados/core/extensions/string_extensions.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';
import 'package:guessthegyarados/features/play/domain/models/clue_attempts.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/shake.dart';

/// The single, shared answer surface for every guessable clue (and the final
/// Pokemon-name guess), shown as the content of a [showModalBottomSheet] —
/// see `clue_answer_sheet.dart`.
///
/// Fewer than 20 options are shown directly as a pickable grid. More than
/// that (the ~1025-name Pokedex search) switches to a search field with a
/// live-filtered, capped result list.
///
/// With [attempts], picks are limited: each wrong option shakes, dims and is
/// struck out for good; once the tries run out every remaining option is
/// disabled (but visibly different from the struck-out wrong ones, and the
/// panel can still be opened to look). A correct pick lights up, locks the
/// rest, and closes the panel after [closeDelay].
class InlineAnswerPanel extends StatefulWidget {
  const InlineAnswerPanel({
    super.key,
    required this.question,
    required this.options,
    required this.onSelect,
    required this.onClose,
    this.coloredOptions = false,
    this.accentColor = GameColors.primary,
    this.attempts,
    this.closeDelay = const Duration(milliseconds: 750),
    this.closeOnWrong = false,
  });

  final String question;
  final List<String> options;
  final bool coloredOptions;
  final Color accentColor;

  /// Called with the picked option; returns whether it was correct.
  final bool Function(String value) onSelect;
  final VoidCallback onClose;
  final ClueAttempts? attempts;
  final Duration closeDelay;

  /// Closes the panel straight after a wrong pick (the caller shows what the
  /// pick turned out to be) instead of leaving it open to try again.
  final bool closeOnWrong;

  @override
  State<InlineAnswerPanel> createState() => _InlineAnswerPanelState();
}

class _InlineAnswerPanelState extends State<InlineAnswerPanel> {
  late List<String> _filtered = _initialOptions;
  final _searchController = TextEditingController();
  String? _solved;

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

  void _select(String option) {
    final attempts = widget.attempts;
    if (_solved != null) return;
    if (attempts != null && (attempts.exhausted || attempts.isWrong(option))) {
      return;
    }

    if (!widget.onSelect(option)) {
      if (widget.closeOnWrong) widget.onClose();
      return;
    }

    if (widget.closeDelay == Duration.zero) {
      widget.onClose();
      return;
    }
    setState(() => _solved = option);
    Future.delayed(widget.closeDelay, () {
      if (mounted) widget.onClose();
    });
  }

  _PillState _stateOf(String option) {
    final attempts = widget.attempts;
    if (_solved != null) {
      return _solved!.toLowerCase() == option.toLowerCase()
          ? _PillState.correct
          : _PillState.locked;
    }
    if (attempts == null) return _PillState.normal;
    if (attempts.isWrong(option)) return _PillState.wrong;
    return attempts.exhausted ? _PillState.locked : _PillState.normal;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        if (widget.attempts != null) widget.attempts!,
      ]),
      builder: (context, _) => _panel(context),
    );
  }

  Widget _panel(BuildContext context) {
    final attempts = widget.attempts;

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
              if (attempts != null) ...[
                _AttemptsMeter(attempts: attempts, solved: _solved != null),
                const SizedBox(width: 8),
              ],
              InkWell(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(24),
                child: const Padding(
                  padding: EdgeInsets.all(12),
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
                          state: _stateOf(option),
                          color: widget.coloredOptions ? getColorFromString(option) : GameColors.surfaceRaised,
                          textColor: widget.coloredOptions ? GameColors.textOnDark : GameColors.textOnLight,
                          onTap: () => _select(option),
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

/// Hearts for the tries left plus a plain-text count, so the number never
/// rests on color alone. Shakes when a try is lost.
class _AttemptsMeter extends StatelessWidget {
  const _AttemptsMeter({required this.attempts, required this.solved});

  final ClueAttempts attempts;
  final bool solved;

  @override
  Widget build(BuildContext context) {
    final left = attempts.left.clamp(0, attempts.maxAttempts);
    final outOfTries = attempts.exhausted && !solved;

    return Shake(
      trigger: attempts.used,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < attempts.maxAttempts; i++)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    i < left ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(i < left),
                    size: 20,
                    color: i < left ? GameColors.danger : GameColors.textMuted,
                  ),
                ),
            ],
          ),
          Text(
            outOfTries ? 'No tries left' : '$left ${left == 1 ? 'try' : 'tries'} left',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: outOfTries ? GameColors.danger : GameColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PillState {
  /// Pickable.
  normal,

  /// Picked and wrong: struck out, dimmed, shaken once. Permanent.
  wrong,

  /// Disabled only because tries ran out (or the answer was found) — dimmed
  /// less than [wrong], with no strike or cross.
  locked,

  /// The right answer.
  correct,
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
    required this.label,
    required this.state,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final _PillState state;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onLight = textColor == GameColors.textOnLight;
    final correct = state == _PillState.correct;
    final wrong = state == _PillState.wrong;

    final pill = Container(
      constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correct
              ? GameColors.success
              : onLight
                  ? Colors.black.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.15),
          width: correct ? 3 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (correct) ...[
            Icon(Icons.check_circle, size: 20, color: textColor),
            const SizedBox(width: 8),
          ],
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
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              decoration: wrong ? TextDecoration.lineThrough : null,
              decorationThickness: 2,
            ),
          ),
          if (wrong) ...[
            const SizedBox(width: 6),
            Icon(Icons.close, size: 18, color: textColor),
          ],
        ],
      ),
    );

    return Shake(
      trigger: wrong,
      child: AnimatedScale(
        scale: correct ? 1.08 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: switch (state) {
            _PillState.wrong => 0.35,
            _PillState.locked => 0.6,
            _ => 1,
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: state == _PillState.normal ? onTap : null,
            child: pill,
          ),
        ),
      ),
    );
  }
}
