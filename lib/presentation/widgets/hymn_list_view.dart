import 'package:flutter/material.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/presentation/widgets/hymn_tile.dart';

class HymnListView extends StatelessWidget {
  final List<HymnModel> hymns;
  final bool isSearchResult;

  const HymnListView({
    super.key,
    required this.hymns,
    required this.isSearchResult,
  });

  @override
  Widget build(BuildContext context) {
    if (hymns.isEmpty) {
      return Center(
        child: Text(
          isSearchResult ? "Tsy nisy hira mifanaraka amin'ny karoka" : "Tsy misy hira",
          style: const TextStyle(fontSize: 11),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hymns.length,
      itemBuilder: (context, index) {
        return HymnTile(
          hymn: hymns[index],
          isSearchResult: isSearchResult,
        );
      },
    );
  }
}
