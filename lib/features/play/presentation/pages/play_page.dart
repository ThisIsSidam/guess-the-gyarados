import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/settings/app_preferences.dart';
import 'package:guessthegyarados/features/profile/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/shared/domain/models/play_pool.dart';
import 'package:guessthegyarados/core/extensions/string_extensions.dart';
import 'package:guessthegyarados/core/settings/haptics.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';
import 'package:guessthegyarados/features/play/domain/models/clue.dart';
import 'package:guessthegyarados/features/play/domain/models/clue_attempts.dart';
import 'package:guessthegyarados/features/play/application/round_settler.dart';
import 'package:guessthegyarados/features/play/domain/models/guess_feedback.dart';
import 'package:guessthegyarados/features/play/domain/models/hint.dart';
import 'package:guessthegyarados/features/play/domain/models/round_outcome.dart';
import 'package:guessthegyarados/features/play/domain/models/round_scoring.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/guess/guess_log_sheet.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/hints/hint_sheet.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/hud/catch_chance_meter.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/hud/hint_button.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/hud/streak_pill.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/folded_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/outlined_text.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/catching/catch_stage_controller.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/catching/pokeball_animation.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/result/round_result_overlay.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/forfeit/forfeit_dialog.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/clue_answer_sheet.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/clue_carousel.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/clue_tile.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/reveal/pokemon_morph_reveal.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_names_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/steps_provider.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/shared/presentation/widgets/audio_player_widget.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tilt_card.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';
import 'package:guessthegyarados/shared/presentation/widgets/screens/error_screen.dart';
import 'package:guessthegyarados/shared/presentation/widgets/screens/loading_screen.dart';

/// Neutral, per-round-stable accent colors shown before any type clue has
/// been revealed — picked from [randomId] so they don't flicker on rebuild,
/// but they carry no hint about the mystery Pokemon's actual type(s).
const _neutralAccents = [
  Colors.teal,
  Colors.orange,
  Colors.pink,
  Colors.cyan,
  Colors.amber,
  Colors.blueGrey,
  Colors.lightGreen,
];

/// Where the end-of-round sequence is, whether the player found the Pokemon
/// or let it go: the options fade out, the page collapses so the Pokemon
/// slides to the center, it's revealed (flip when found, morph when given up
/// on), and then [revealed] is the stage for what follows — the catch
/// animation, or the "It was ..." caption.
enum _EndPhase { none, fading, moving, revealing, revealed }

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {
  // The pool chosen on the home page; points are scaled by its difficulty.
  final PlayPool _pool = PlayPool.byName(getIt<AppPreferences>().playPool);

  // The catch streak going into this round.
  final int _streakBefore = getIt<UserProfileRepository>().getProfile().catchStreak;

  late final randomId = Random().nextInt(_pool.maxId) + 1; // Randomly pick a pokemon id
  bool isShiny = false;

  @override // Lucky enough for a shiny?
  void initState() {
    final shinyChances = Random().nextInt(1000);
    if (shinyChances == 69) isShiny = true; // ¯\_(ツ)_/¯ (¬‿¬)

    super.initState();
  }

  late int stepsCount = ref.read(stepsCounterProvider);

  bool pokemonGuessedCorrectly = false;

  _EndPhase endPhase = _EndPhase.none;

  bool get _ending => endPhase != _EndPhase.none;

  // True once the round's final animation is done and the player can move on.
  bool showContinue = false;

  // What the round was worth; set the moment the end-of-round sequence
  // reaches its final stage (the catch is rolled then).
  RoundOutcome? _outcome;

  // Hints bought this round, and the coin balance they're paid from.
  final Set<Hint> _hints = {};
  late int _coins = getIt<UserProfileRepository>().getProfile().coins;

  // Wrong names tried so far (each is answered attribute by attribute), and
  // whether the round ended because they ran out.
  final List<GuessEntry> _guesses = [];
  bool _fled = false;

  // Wrong choice-clue picks plus wrong names; a round with none is "perfect".
  int _wrongPicks = 0;

  // Shrinks/flashes the Pokemon sprite as the ball takes it in; driven by the
  // catch animation.
  final _catchStage = CatchStageController();

  @override
  void dispose() {
    _catchStage.dispose();
    for (final attempts in _attempts.values) {
      attempts.dispose();
    }
    super.dispose();
  }

  // Which clues have already been guessed/revealed this round.
  final Set<String> revealedClueIds = {};

  // Tries spent per choice clue, kept for the whole round so closing and
  // reopening a clue's dialog never refunds them.
  final Map<String, ClueAttempts> _attempts = {};

  ClueAttempts _attemptsFor(ClueSpec clue) =>
      _attempts.putIfAbsent(clue.id, () => ClueAttempts(clue.maxAttempts));

  // Out of tries with the answer still unfound.
  Set<String> get lockedClueIds => {
        for (final entry in _attempts.entries)
          if (entry.value.exhausted && !revealedClueIds.contains(entry.key))
            entry.key,
      };

  Color get _neutralAccent =>
      _neutralAccents[randomId % _neutralAccents.length];

  @override
  Widget build(BuildContext context) {
    final arceusImage = Image.asset(
      arceusImagePath,
      height: 200,
      width: 200,
      fit: BoxFit.contain,
    );

    // Load data
    final pokemonAsync = ref.watch(pokemonProvider(randomId));
    final pokemonsMap = ref.watch(pokemonNamesProvider).value;
    stepsCount = ref.watch(stepsCounterProvider);

    return pokemonAsync.when(
      data: (thisPokemon) {
        debugPrint(thisPokemon.name + thisPokemon.bst.toString());

        final catalog = buildClueCatalog(thisPokemon);
        final accentColor = _accentColorFor(catalog);

        return PopScope(
          // The phone's back button gets the same treatment as the on-screen
          // one: confirm first, never leave mid-round silently.
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) onBackPressed(thisPokemon);
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: FoldedBackdrop(
              accentColor: accentColor,
              child: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        topBar(thisPokemon),
                        Expanded(
                          child: revealArea(
                              thisPokemon, pokemonsMap ?? const {}),
                        ),
                        // Collapses to nothing once the options have faded,
                        // which is what lets the reveal slide to center.
                        AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: endPhase.index >= _EndPhase.moving.index
                              ? const SizedBox(width: double.infinity)
                              : AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: _ending ? 0 : 1,
                                  child: IgnorePointer(
                                    ignoring: _ending,
                                    child: Column(
                                      children: [
                                        infoRow(catalog, accentColor),
                                        const SizedBox(height: 8),
                                        ClueCarousel(
                                          cardGroups: catalog.cardGroups,
                                          cardTitles: catalog.cardTitles,
                                          revealedIds: revealedClueIds,
                                          lockedIds: lockedClueIds,
                                          accentColor: accentColor,
                                          onClueTap: (clue) =>
                                              onClueTap(clue, accentColor),
                                        ),
                                        const SizedBox(height: 8),
                                        getSubmissionBar(
                                            thisPokemon,
                                            pokemonsMap?.values.toList() ??
                                                const [],
                                            accentColor),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: showContinue ? 1 : 0,
                          child: IgnorePointer(
                            ignoring: !showContinue,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GameIconBadge(
                                  semanticLabel: 'Home',
                                  size: 60,
                                  onPressed: leavePage,
                                  child: const Icon(Icons.home_rounded,
                                      color: GameColors.textOnLight, size: 30),
                                ),
                                const SizedBox(width: 16),
                                GameButton(
                                  color: GameColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 32),
                                  onPressed: nextPokemon,
                                  child: const Text(
                                    'NEXT POKEMON',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: GameColors.textOnLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (err, stack) {
        debugPrint("[playPage] Error: $err");
        debugPrint("[playPage] stack : $stack");
        return ErrorScreen(
          image: arceusImage,
          errorText: err.toString(),
        );
      },
      loading: () => HoveringImageLoadingScreen(
        image: arceusImage,
        text: "Lemme think",
        accentColor: _neutralAccent,
      ),
    );
  }

  // The neutral, per-round accent until a type is revealed; blends towards
  // (and eventually becomes) the real type color(s) as Type 1/Type 2 clues
  // are answered correctly.
  Color _accentColorFor(ClueCatalog catalog) {
    final type1 = catalog.infoRow[0];
    final type2 = catalog.infoRow[1];
    final revealed1 = revealedClueIds.contains(type1.id);
    final revealed2 = revealedClueIds.contains(type2.id);

    if (!revealed1 && !revealed2) return _neutralAccent;
    if (revealed1 && revealed2) {
      return Color.lerp(getColorFromString(type1.answer),
          getColorFromString(type2.answer), 0.5)!;
    }
    return getColorFromString((revealed1 ? type1 : type2).answer);
  }

  // Deliberately very different: a soft tick for a right pick, a hard
  // double-buzz for a wrong one, so the two are never confused by feel.
  void _feedback(bool success) {
    if (success) {
      Haptics.light();
    } else {
      Haptics.doubleBuzz();
    }
  }

  void onClueTap(ClueSpec clue, Color accentColor) {
    if (revealedClueIds.contains(clue.id)) return;

    if (clue.kind == ClueKind.boolean) {
      // Nothing to pick — a boolean fact just reveals itself, at the cost
      // of a step.
      setState(() {
        revealedClueIds.add(clue.id);
        ref.read(stepsCounterProvider.notifier).increment();
      });
      _feedback(true);
      return;
    }

    final attempts = _attemptsFor(clue);
    showAnswerSheet(
      context: context,
      question: clue.dialogLabel,
      options: clue.options!,
      correctAnswer: clue.answer,
      coloredOptions: clue.coloredOptions,
      accentColor: accentColor,
      attempts: attempts,
      onAttempt: (correct, value) {
        ref.read(stepsCounterProvider.notifier).increment();
        _feedback(correct);
        if (correct) {
          setState(() => revealedClueIds.add(clue.id));
        } else {
          _wrongPicks++;
          attempts.recordWrong(value);
          // Refreshes the "out of tries" markers behind the dialog.
          setState(() {});
        }
      },
    );
  }

  Future<void> onSubmitTap(
      PokemonEntity pokemon, List<String> pokemonNames, Color accentColor) async {
    final idsByName = {
      for (final entry in (ref.read(pokemonNamesProvider).value ?? {}).entries)
        entry.value: entry.key,
    };
    var missed = false;

    await showAnswerSheet(
      context: context,
      question: "Who's that Pokemon?",
      options: pokemonNames,
      correctAnswer: pokemon.name,
      accentColor: accentColor,
      // No success flourish (the end-of-round sequence takes over), and a wrong
      // name closes the picker so the answer to it can be shown.
      closeDelay: Duration.zero,
      closeOnWrong: true,
      onAttempt: (correct, value) {
        ref.read(stepsCounterProvider.notifier).increment();
        _feedback(correct);
        if (correct) {
          foundPokemon(pokemon);
        } else {
          _wrongPicks++;
          missed = true;
          _recordGuess(value, idsByName[value] ?? 0);
        }
      },
    );

    if (!missed || !mounted || _ending) return;
    if (_guesses.length >= maxNameGuesses) {
      await forfeitRound(pokemon, fled: true);
      return;
    }
    _showGuessLog(pokemon, pokemonNames, accentColor, justMissed: true);
  }

  // Starts looking the guess up straight away so its comparison is usually
  // ready by the time the log opens.
  void _recordGuess(String name, int id) {
    final data = id == 0
        ? Future<PokemonEntity>.error(StateError('Unknown Pokemon: $name'))
        : getIt<PokemonRepository>().getOrFetch(id);
    data.ignore(); // Errors surface in the log; don't also report them here.
    setState(() => _guesses.add(GuessEntry(id: id, name: name, data: data)));
  }

  void _showGuessLog(
    PokemonEntity pokemon,
    List<String> pokemonNames,
    Color accentColor, {
    required bool justMissed,
  }) {
    showGuessLogSheet(
      context: context,
      entries: _guesses,
      answer: pokemon,
      justMissed: justMissed,
      onGuessAgain: _ending
          ? null
          : () => onSubmitTap(pokemon, pokemonNames, accentColor),
    );
  }

  // Waits, then moves the end-of-round sequence to [phase]. False if the page
  // was left in the meantime.
  Future<bool> _advanceTo(_EndPhase phase, int afterMs) async {
    await Future.delayed(Duration(milliseconds: afterMs));
    if (!mounted) return false;
    setState(() => endPhase = phase);
    return true;
  }

  // Correct guess: options fade (300ms) -> page collapses so the Pokemon
  // slides to center (500ms) -> it flips to the real thing (600ms) -> the
  // ball is thrown. The catch itself is rolled/recorded by [CatchingWidget]
  // when it appears.
  Future<void> foundPokemon(PokemonEntity pokemon) async {
    setState(() {
      pokemonGuessedCorrectly = true;
      endPhase = _EndPhase.fading;
    });
    if (!await _advanceTo(_EndPhase.moving, 320)) return;
    if (!await _advanceTo(_EndPhase.revealing, 550)) return;
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    setState(() {
      _outcome = RoundSettler.settleGuess(
        pokemon: pokemon,
        isShiny: isShiny,
        steps: stepsCount,
        wrongPicks: _wrongPicks,
        pool: _pool,
      );
      endPhase = _EndPhase.revealed;
    });
  }

  Widget revealArea(PokemonEntity thisPokemon, Map<int, String> pokemonNames) {
    const imageSize = 220.0;
    final giveUpRevealed =
        endPhase == _EndPhase.revealed && !pokemonGuessedCorrectly;

    // The cry is a strong hint: it only plays once bought, or at round's end.
    final reveal = AudioPlayerWidget(
      audioLink: thisPokemon.cry,
      enabled: endPhase == _EndPhase.revealed || _hints.contains(Hint.cry),
      child: TiltCard(
        child: SizedBox(
          height: imageSize,
          width: imageSize,
          child: FlipCard(
            // Found it: flip over once the page has settled.
            flipped: pokemonGuessedCorrectly &&
                endPhase.index >= _EndPhase.revealing.index,
            front: PokemonMorphReveal(
              pokemonNames: pokemonNames,
              excludeId: thisPokemon.id,
              size: imageSize,
              // Only when giving up: a found Pokemon flips instead of morphing.
              target: _ending && !pokemonGuessedCorrectly
                  ? MorphTarget(
                      id: thisPokemon.id,
                      name: thisPokemon.name,
                      isShiny: isShiny,
                    )
                  : null,
              resolve: !pokemonGuessedCorrectly &&
                  endPhase.index >= _EndPhase.revealing.index,
              silhouette: _hints.contains(Hint.silhouette)
                  ? MorphTarget(id: thisPokemon.id, name: thisPokemon.name)
                  : null,
            ),
            back: PokemonSpriteImage(
              pokemonId: thisPokemon.id,
              pokemonName: thisPokemon.name,
              isShiny: isShiny,
              showLoadingIndicator: false,
            ),
          ),
        ),
      ),
    );

    // The ball takes the sprite in (and a failed catch lets it back out); the
    // wrappers stay in the tree permanently so the sprite's state is never
    // rebuilt when they start doing something.
    final stagedReveal = ListenableBuilder(
      listenable: _catchStage,
      child: reveal,
      builder: (context, child) {
        final absorb = _catchStage.absorb;
        return Transform.scale(
          scale: max(1 - absorb, 0.0001),
          alignment: Alignment(0, _catchStage.anchorY),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: (absorb * 1.6).clamp(0.0, 1.0)),
              BlendMode.srcATop,
            ),
            child: child,
          ),
        );
      },
    );

    // The caption is laid out below the image without moving it, so the image
    // itself stays exactly centered through the whole sequence.
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          stagedReveal,
          if (_hints.contains(Hint.cry) && !_ending)
            IgnorePointer(
              child: Transform.translate(
                offset: const Offset(imageSize / 2 - 14, imageSize / 2 - 14),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x33000000), offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.volume_up_rounded,
                      size: 24, color: GameColors.backgroundDeep),
                ),
              ),
            ),
          if (_hints.contains(Hint.firstLetter))
            Positioned(
              top: constraints.maxHeight / 2 + imageSize / 2 + 8,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _ending ? 0 : 1,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                            color: GameColors.primaryDeep, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Text(
                      Hint.maskName(thisPokemon.name),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: GameColors.textOnLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_streakBefore > 0)
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _ending ? 0 : 1,
                  child: StreakPill(streak: _streakBefore),
                ),
              ),
            ),
          if (pokemonGuessedCorrectly && endPhase == _EndPhase.revealed)
            Positioned.fill(
              child: PokeBallCatchAnimation(
                isCaught: _outcome!.caught,
                pokemonName: thisPokemon.name,
                isShiny: isShiny,
                stage: _catchStage,
                onFinished: () {
                  if (mounted) setState(() => showContinue = true);
                },
              ),
            ),
          if (showContinue && _outcome != null)
            Positioned.fill(child: RoundResultOverlay(outcome: _outcome!)),
          Positioned(
            top: constraints.maxHeight / 2 + imageSize / 2 + 8,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: giveUpRevealed ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                offset: giveUpRevealed
                    ? Offset.zero
                    : const Offset(0, 0.3),
                child: Column(
                  children: [
                    Text(
                      _fled ? 'IT FLED. IT WAS' : 'IT WAS',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        color: GameColors.textMuted,
                      ),
                    ),
                    OutlinedText(
                      '${thisPokemon.name.capitalize}!',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 38),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Replaces the old AppBar — a plain row on the backdrop itself so there's
  // no separate Material surface/shadow between it and the rest of the page.
  Widget topBar(PokemonEntity thisPokemon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onBackPressed(thisPokemon),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  pokemonGuessedCorrectly ||
                          endPhase == _EndPhase.revealed
                      ? Icons.keyboard_return
                      : Icons.arrow_back,
                  color: GameColors.textOnLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          HintButton(
            coins: _coins,
            onTap: _ending ? null : () => _openHints(),
          ),
          const Spacer(),
          CatchChanceMeter(
            chance: RoundScoring.meter(stepsCount),
            steps: stepsCount,
          ),
        ],
      ),
    );
  }

  void _openHints() {
    showHintSheet(
      context: context,
      coins: _coins,
      bought: _hints,
      onBuy: (hint) {
        if (!getIt<UserProfileRepository>().spendCoins(hint.cost)) return null;
        setState(() {
          _hints.add(hint);
          _coins -= hint.cost;
        });
        _feedback(true);
        return _coins;
      },
    );
  }

  Widget infoRow(ClueCatalog catalog, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final clue in catalog.infoRow) ...[
            if (clue != catalog.infoRow.first) const SizedBox(width: 12),
            ClueRowChip(
              clue: clue,
              revealed: revealedClueIds.contains(clue.id),
              locked: lockedClueIds.contains(clue.id),
              onTap: () => onClueTap(clue, accentColor),
            ),
          ],
        ],
      ),
    );
  }

  // Only rendered pre-guess — the exit/return control lives in the app bar.
  Widget getSubmissionBar(
      PokemonEntity pokemon, List<String> pokemonNames, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: submitSearchBar(
                () => onSubmitTap(pokemon, pokemonNames, accentColor),
                accentColor),
          ),
          if (_guesses.isNotEmpty) ...[
            const SizedBox(width: 10),
            GameIconBadge(
              semanticLabel: 'Your wrong guesses',
              onPressed: () => _showGuessLog(pokemon, pokemonNames, accentColor,
                  justMissed: false),
              child: const Icon(Icons.history_rounded,
                  color: GameColors.textOnLight, size: 28),
            ),
          ],
        ],
      ),
    );
  }

  Widget submitSearchBar(VoidCallback onTap, Color accentColor) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GameColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: accentColor),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Found it? Search the name...",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: GameColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.favorite, size: 20, color: GameColors.danger),
            const SizedBox(width: 3),
            Text(
              '${(maxNameGuesses - _guesses.length).clamp(0, maxNameGuesses)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: GameColors.textOnLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Back button (on-screen or the phone's). Mid-round it asks first; once
  // the round is over (caught/missed) it just leaves.
  Future<void> onBackPressed(PokemonEntity pokemon) async {
    if (_ending && endPhase != _EndPhase.revealed) return;
    if (pokemonGuessedCorrectly || endPhase == _EndPhase.revealed) {
      leavePage();
      return;
    }

    final letGo = await showForfeitDialog(context);
    if (!letGo || !mounted) return;
    await forfeitRound(pokemon);
  }

  Future<void> forfeitRound(PokemonEntity pokemon, {bool fled = false}) async {
    setState(() {
      _fled = fled;
      _outcome = RoundSettler.settleForfeit(
        pokemon: pokemon,
        steps: ref.read(stepsCounterProvider),
        pool: _pool,
      );
      endPhase = _EndPhase.fading;
    });
    // Options fade (300ms) -> page collapses so the image slides to center
    // (500ms) -> it morphs into the real Pokemon (900ms) -> caption.
    if (!await _advanceTo(_EndPhase.moving, 320)) return;
    if (!await _advanceTo(_EndPhase.revealing, 550)) return;
    if (!await _advanceTo(_EndPhase.revealed, 1000)) return;
    setState(() => showContinue = true);
  }

  // Shared by every way out of a finished round: pick up the new catches and
  // achievements, and tell the player about any achievements.
  void _closeRound() {
    ref.read(caughtPokemonProvider.notifier).refresh();
    final newAchievements =
        ref.read(caughtPokemonProvider).newlyReceivedAchievements;

    if (newAchievements.isNotEmpty) {
      final snackBar = SnackBar(
        content: Row(
          children: [
            Text(
                "You just received ${newAchievements.length == 1 ? 'an' : 'some'} achievement${newAchievements.length == 1 ? '' : 's'}!"),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void leavePage() {
    _closeRound();
    Navigator.pop(context);
  }

  // Straight into the next round instead of back through the home page.
  void nextPokemon() {
    _closeRound();
    ref.read(stepsCounterProvider.notifier).reborn();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PlayPage()),
    );
  }
}
