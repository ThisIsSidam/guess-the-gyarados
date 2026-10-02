import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/settings/app_preferences.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/domain/models/play_pool.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tap_bounce.dart';

/// Picks which Pokemon the next round draws from. Each option shows its point
/// multiplier, so choosing an easier pool is a visible trade.
class PoolSelector extends StatefulWidget {
  const PoolSelector({super.key});

  @override
  State<PoolSelector> createState() => _PoolSelectorState();
}

class _PoolSelectorState extends State<PoolSelector> {
  final _prefs = getIt<AppPreferences>();
  late PlayPool _selected = PlayPool.byName(_prefs.playPool);

  void _select(PlayPool pool) {
    setState(() => _selected = pool);
    _prefs.setPlayPool(pool.name);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final pool in PlayPool.values) ...[
          if (pool != PlayPool.values.first) const SizedBox(width: 10),
          _PoolChip(
            pool: pool,
            selected: pool == _selected,
            onTap: () => _select(pool),
          ),
        ],
      ],
    );
  }
}

class _PoolChip extends StatelessWidget {
  const _PoolChip({
    required this.pool,
    required this.selected,
    required this.onTap,
  });

  final PlayPool pool;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final multiplier = pool.difficulty == 1
        ? 'full pts'
        : 'x${pool.difficulty} pts';

    return TapBounce(
      onTap: onTap,
      semanticLabel: '${pool.label}, $multiplier${selected ? ', selected' : ''}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? GameColors.gold : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? GameColors.goldDeep : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? GameColors.goldDeep : const Color(0x33000000),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pool.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: GameColors.textOnLight,
              ),
            ),
            Text(
              multiplier,
              style: TextStyle(
                fontSize: 13,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: selected ? GameColors.textOnLight : GameColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
