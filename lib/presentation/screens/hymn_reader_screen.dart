import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/presentation/cubits/fihirana_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';
import 'package:baiboly_apk/presentation/widgets/hymn_verse_tile.dart';

class HymnReaderScreen extends StatefulWidget {
  final HymnModel hymn;

  const HymnReaderScreen({super.key, required this.hymn});

  @override
  State<HymnReaderScreen> createState() => _HymnReaderScreenState();
}

class _HymnReaderScreenState extends State<HymnReaderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FihiranaCubit>().loadHymnDetails(widget.hymn);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String categoryName = widget.hymn.category == 'ffpm' ? "FFPM" : (widget.hymn.category == 'fanampiny' ? "Fanampiny" : "Antema");

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 40,
        leading: IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text("$categoryName - Hira ${widget.hymn.number}", style: theme.textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
        actions: [
          BlocBuilder<FihiranaCubit, FihiranaState>(
            builder: (context, state) {
              bool isBookmarked = state is HymnLoaded && state.isBookmarked;
              return IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline, size: 20, color: isBookmarked ? theme.colorScheme.primary : null),
                onPressed: () => context.read<FihiranaCubit>().toggleHymnBookmark(widget.hymn.id),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FihiranaCubit, FihiranaState>(
        builder: (context, state) {
          if (state is FihiranaLoading) return const Center(child: CircularProgressIndicator());
          if (state is HymnLoaded) {
            final verses = state.verses;
            if (verses.isEmpty) return const Center(child: Text("Tsy misy paroles hita.", style: TextStyle(fontSize: 11)));

            return BlocBuilder<PreferencesCubit, PreferencesState>(
              builder: (context, prefs) {
                final double baseFontSize = prefs.fontSize > 18 ? 15.0 : prefs.fontSize - 1.0;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  children: [
                    if (widget.hymn.title.isNotEmpty) ...[
                      Center(child: Text(widget.hymn.title.toUpperCase(), textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontSize: baseFontSize + 1, fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
                      const SizedBox(height: 4),
                    ],
                    if (widget.hymn.author.isNotEmpty) ...[
                      Center(child: Text(widget.hymn.author, style: theme.textTheme.bodyMedium?.copyWith(fontSize: baseFontSize - 3, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.6)))),
                    ],
                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 16),
                    ...verses.map((verse) => HymnVerseTile(verse: verse, baseFontSize: baseFontSize)),
                  ],
                );
              },
            );
          }
          if (state is FihiranaError) return Center(child: Text(state.message, style: const TextStyle(fontSize: 11)));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
