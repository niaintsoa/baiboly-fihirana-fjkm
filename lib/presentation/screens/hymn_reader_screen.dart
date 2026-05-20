import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/presentation/cubits/fihirana_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';

class HymnReaderScreen extends StatefulWidget {
  final HymnModel hymn;

  const HymnReaderScreen({
    super.key,
    required this.hymn,
  });

  @override
  State<HymnReaderScreen> createState() => _HymnReaderScreenState();
}

class _HymnReaderScreenState extends State<HymnReaderScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les détails du chant
    context.read<FihiranaCubit>().loadHymnDetails(widget.hymn);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Déterminer le titre compact de la catégorie
    String categoryName = "Fihirana";
    if (widget.hymn.category == 'ffpm') categoryName = "FFPM";
    if (widget.hymn.category == 'fanampiny') categoryName = "Fanampiny";
    if (widget.hymn.category == 'antema') categoryName = "Antema";

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "$categoryName - Hira ${widget.hymn.number}",
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Bouton favori lié à la base de données
          BlocBuilder<FihiranaCubit, FihiranaState>(
            builder: (context, state) {
              bool isBookmarked = false;
              if (state is HymnLoaded) {
                isBookmarked = state.isBookmarked;
              }
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  size: 20,
                  color: isBookmarked ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  context.read<FihiranaCubit>().toggleHymnBookmark(widget.hymn.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBookmarked 
                            ? "Nesorina tamin'ny hira tianao" 
                            : "Nampiana tamin'ny hira tianao",
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FihiranaCubit, FihiranaState>(
        builder: (context, state) {
          if (state is FihiranaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HymnLoaded) {
            final verses = state.verses;

            if (verses.isEmpty) {
              return const Center(
                child: Text(
                  "Tsy misy paroles hita ho an'ity hira ity.",
                  style: TextStyle(fontSize: 11),
                ),
              );
            }

            return BlocBuilder<PreferencesCubit, PreferencesState>(
              builder: (context, prefs) {
                // Adapte la taille de la police pour rester lisible et compact
                final double baseFontSize = prefs.fontSize > 18 ? 15.0 : prefs.fontSize - 1.0;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  children: [
                    // Titre du chant
                    if (widget.hymn.title.isNotEmpty) ...[
                      Center(
                        child: Text(
                          widget.hymn.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: baseFontSize + 1,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Auteur (si présent)
                    if (widget.hymn.author.isNotEmpty) ...[
                      Center(
                        child: Text(
                          widget.hymn.author,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: baseFontSize - 3,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 16),

                    // Couplets & Refrains
                    ...verses.map((verse) {
                      final bool isChorus = verse.isChorus;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: isChorus
                            ? const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0)
                            : EdgeInsets.zero,
                        decoration: isChorus
                            ? BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: theme.colorScheme.primary.withOpacity(0.4),
                                    width: 3,
                                  ),
                                ),
                              )
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Numéro de couplet / Indicateur de refrain
                            if (isChorus)
                              Text(
                                "Fiverenany :",
                                style: TextStyle(
                                  fontSize: baseFontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else if (verse.verseNumber > 0)
                              Text(
                                "${verse.verseNumber}.",
                                style: TextStyle(
                                  fontSize: baseFontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            
                            const SizedBox(height: 4),

                            // Paroles
                            Text(
                              verse.lyrics,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: baseFontSize,
                                height: 1.4,
                                fontStyle: isChorus ? FontStyle.italic : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          }

          if (state is FihiranaError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(fontSize: 11),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
