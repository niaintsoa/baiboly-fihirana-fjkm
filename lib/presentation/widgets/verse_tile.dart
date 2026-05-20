import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/core/utils/text_cleaner.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';
import 'package:baiboly_apk/presentation/widgets/verse_actions_sheet.dart';

class VerseTile extends StatelessWidget {
  final VerseModel verse;
  final double baseFontSize;

  const VerseTile({
    super.key,
    required this.verse,
    required this.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cleanedText = TextCleaner.cleanVerseText(verse.text, verse.verse);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: InkWell(
        onLongPress: () => _showActions(context),
        onDoubleTap: () {
          context.read<BookmarkCubit>().toggleBookmark(verse);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Voaova ny andininy tianao (${verse.bookName} ${verse.chapter}:${verse.verse})",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "${verse.verse} ",
                  style: TextStyle(
                    fontSize: baseFontSize - 3,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: cleanedText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: baseFontSize,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) => VerseActionsSheet(verse: verse),
    );
  }
}
