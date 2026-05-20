import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';
import 'package:baiboly_apk/presentation/widgets/verse_tile.dart';

class VerseListView extends StatelessWidget {
  final List<VerseModel> verses;

  const VerseListView({super.key, required this.verses});

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Tsy misy andininy ato amin'ity toko ity.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, prefs) {
        final double baseFontSize = prefs.fontSize > 18 ? 15.0 : prefs.fontSize - 2.0;

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 50),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            return VerseTile(
              verse: verses[index],
              baseFontSize: baseFontSize,
            );
          },
        );
      },
    );
  }
}
