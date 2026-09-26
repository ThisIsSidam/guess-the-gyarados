import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/theme_provider.g.dart';

/// Simplified to a plain function: the old `ThemeProvider.setTheme()` had
/// zero call sites, so theme is effectively a constant today.
@riverpod
ThemeData appTheme(Ref ref) => gyaradosTheme;
