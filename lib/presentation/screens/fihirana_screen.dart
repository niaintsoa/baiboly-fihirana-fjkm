import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/presentation/cubits/fihirana_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/fihirana_search_cubit.dart';
import 'package:baiboly_apk/presentation/screens/hymn_reader_screen.dart';

class FihiranaScreen extends StatefulWidget {
  const FihiranaScreen({super.key});

  @override
  State<FihiranaScreen> createState() => _FihiranaScreenState();
}

class _FihiranaScreenState extends State<FihiranaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // Catégories correspondant aux 3 onglets
  final List<String> _categories = ['ffpm', 'fanampiny', 'antema'];
  final List<String> _tabLabels = ['Fihirana FFPM', 'Fanampiny', 'Antema'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Charger la première catégorie par défaut
    context.read<FihiranaCubit>().loadHymns(_categories[0]);
    
    // Écouter le changement d'onglet pour recharger la liste correspondante
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _searchController.clear();
        context.read<FihiranaSearchCubit>().clearSearch();
        context.read<FihiranaCubit>().loadHymns(_categories[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête minimaliste
              Text(
                "Fihirana sy Antema",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Barre de recherche compacte
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.search, size: 16),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: "Hikaroka hira (laharana, lohateny, teny...)",
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (query) {
                          context.read<FihiranaSearchCubit>().search(query);
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          context.read<FihiranaSearchCubit>().clearSearch();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Onglets compacts "fit design"
              TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                tabs: _tabLabels.map((label) => Tab(height: 28, text: label)).toList(),
              ),
              const SizedBox(height: 8),

              // Liste principale ou résultats de recherche
              Expanded(
                child: BlocBuilder<FihiranaSearchCubit, FihiranaSearchState>(
                  builder: (context, searchState) {
                    if (searchState is FihiranaSearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (searchState is FihiranaSearchSuccess) {
                      return _buildHymnList(searchState.results, isSearchResult: true);
                    } else if (searchState is FihiranaSearchError) {
                      return Center(child: Text(searchState.message, style: const TextStyle(fontSize: 11)));
                    }

                    // Si pas de recherche active, afficher la liste classique de la catégorie
                    return BlocBuilder<FihiranaCubit, FihiranaState>(
                      builder: (context, state) {
                        if (state is FihiranaLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is FihiranaLoaded) {
                          return _buildHymnList(state.hymns, isSearchResult: false);
                        } else if (state is FihiranaError) {
                          return Center(child: Text(state.message, style: const TextStyle(fontSize: 11)));
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHymnList(List<HymnModel> hymns, {required bool isSearchResult}) {
    final theme = Theme.of(context);

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
        final hymn = hymns[index];
        
        // Label de catégorie compact pour les résultats de recherche multi-catégories
        String categoryBadge = "";
        if (isSearchResult) {
          if (hymn.category == 'ffpm') categoryBadge = "FFPM";
          if (hymn.category == 'fanampiny') categoryBadge = "Fanampiny";
          if (hymn.category == 'antema') categoryBadge = "Antema";
        }

        return InkWell(
          onTap: () {
            _searchFocusNode.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HymnReaderScreen(hymn: hymn),
              ),
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.04),
              ),
            ),
            child: Row(
              children: [
                // Numéro du chant
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    "${hymn.number}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Titre
                Expanded(
                  child: Text(
                    hymn.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Badge de catégorie si recherche
                if (categoryBadge.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      categoryBadge,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
