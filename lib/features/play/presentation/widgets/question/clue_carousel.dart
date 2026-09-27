import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/domain/models/clue.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/clue_tile.dart';

/// A horizontally-scrollable carousel of clue cards: the centered card sits
/// at full size, its neighbours peek in from either side, and each card's
/// height follows however many clues it holds.
class ClueCarousel extends StatefulWidget {
  const ClueCarousel({
    super.key,
    required this.cardGroups,
    required this.cardTitles,
    required this.revealedIds,
    required this.accentColor,
    required this.onClueTap,
  });

  final List<List<ClueSpec>> cardGroups;
  final List<String> cardTitles;
  final Set<String> revealedIds;
  final Color accentColor;
  final void Function(ClueSpec clue) onClueTap;

  @override
  State<ClueCarousel> createState() => _ClueCarouselState();
}

class _ClueCarouselState extends State<ClueCarousel> {
  final _controller = PageController(viewportFraction: 0.78);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _pageOffsetFor(int index) {
    if (!_controller.hasClients || !_controller.position.haveDimensions) return index == 0 ? 0 : 1;
    final page = _controller.page ?? _controller.initialPage.toDouble();
    return page - index;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.cardGroups.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delta = _pageOffsetFor(index).clamp(-1.0, 1.0).abs();
              final scale = 1 - delta * 0.08;
              final opacity = 1 - delta * 0.3;
              return Center(
                child: Opacity(
                  opacity: opacity.clamp(0.7, 1.0),
                  child: Transform.scale(scale: scale, child: child),
                ),
              );
            },
            child: _ClueCard(
              title: widget.cardTitles[index],
              clues: widget.cardGroups[index],
              revealedIds: widget.revealedIds,
              accentColor: widget.accentColor,
              onClueTap: widget.onClueTap,
            ),
          );
        },
      ),
    );
  }
}

class _ClueCard extends StatelessWidget {
  const _ClueCard({
    required this.title,
    required this.clues,
    required this.revealedIds,
    required this.accentColor,
    required this.onClueTap,
  });

  final String title;
  final List<ClueSpec> clues;
  final Set<String> revealedIds;
  final Color accentColor;
  final void Function(ClueSpec clue) onClueTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: GameColors.textOnLight),
          ),
          const SizedBox(height: 6),
          ...clues.map(
            (clue) => ClueCardRow(
              clue: clue,
              revealed: revealedIds.contains(clue.id),
              accentColor: accentColor,
              onTap: () => onClueTap(clue),
            ),
          ),
        ],
      ),
    );
  }
}
