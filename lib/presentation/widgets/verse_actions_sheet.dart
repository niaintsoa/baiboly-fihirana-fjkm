import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/fandaharana_item.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/fandaharana_cubit.dart';

class VerseActionsSheet extends StatelessWidget {
  final VerseModel verse;

  const VerseActionsSheet({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<bool>(
      future: context.read<BookmarkCubit>().checkIsBookmarked(verse),
      builder: (context, snapshot) {
        final isBookmarked = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${verse.bookName} ${verse.chapter}:${verse.verse}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                verse.text,
                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: theme.colorScheme.primary, size: 18),
                title: Text(isBookmarked ? "Esory amin'ny tiana" : "Ampidiro amin'ny tiana", style: const TextStyle(fontSize: 12)),
                onTap: () {
                  context.read<BookmarkCubit>().toggleBookmark(verse);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.playlist_add, size: 18),
                title: const Text("Ampidiro anaty fandaharana", style: TextStyle(fontSize: 12)),
                onTap: () {
                  final item = FandaharanaItem(
                    id: 'verse_${verse.bookNumber}_${verse.chapter}_${verse.verse}',
                    type: 'verse',
                    title: '${verse.bookName} ${verse.chapter}:${verse.verse}',
                    subtitle: verse.text,
                    data: jsonEncode(verse.toMap()),
                  );
                  context.read<FandaharanaCubit>().addItem(item);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tafiditra anaty fandaharana'), duration: Duration(seconds: 2)),
                  );
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.copy, size: 18),
                title: const Text("Kopia ny andininy", style: TextStyle(fontSize: 12)),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: "${verse.text} (${verse.bookName} ${verse.chapter}:${verse.verse})"));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.share, size: 18),
                title: const Text("Zaraina", style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
