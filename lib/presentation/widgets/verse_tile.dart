import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';
import 'package:baiboly_apk/core/utils/text_cleaner.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';
import 'package:baiboly_apk/presentation/widgets/verse_actions_sheet.dart';

class VerseTile extends StatelessWidget {
  final VerseModel verse;
  final double baseFontSize;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const VerseTile({
    super.key,
    required this.verse,
    required this.baseFontSize,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cleanedText = TextCleaner.cleanVerseText(verse.text, verse.verse);
    final justifyText = context.select((PreferencesCubit c) => c.state.justifyText);

    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, bookmarkState) {
        bool isBookmarked = false;
        if (bookmarkState is BookmarkLoaded) {
          isBookmarked = bookmarkState.bookmarks.any((b) =>
              b.bookNumber == verse.bookNumber &&
              b.chapter == verse.chapter &&
              b.verse == verse.verse);
        }

        Color highlightColor = Colors.transparent;
        if (isHighlighted) {
          highlightColor = theme.colorScheme.primary.withOpacity(0.12);
        } else if (isBookmarked) {
          highlightColor = theme.colorScheme.primary.withOpacity(0.06);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: InkWell(
            onTap: onTap,
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: highlightColor,
                borderRadius: BorderRadius.circular(4),
                border: isBookmarked
                    ? Border(
                        left: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.6),
                          width: 2.5,
                        ),
                      )
                    : null,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: isBookmarked ? 4.0 : 0.0),
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
                  textAlign: justifyText ? TextAlign.justify : TextAlign.start,
                ),
              ),
            ),
          ),
        );
      },
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
