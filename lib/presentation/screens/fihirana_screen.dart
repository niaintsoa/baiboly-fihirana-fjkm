import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/presentation/cubits/fihirana_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/fihirana_search_cubit.dart';
import 'package:baiboly_apk/presentation/widgets/hymn_list_view.dart';

class FihiranaScreen extends StatefulWidget {
  const FihiranaScreen({super.key});

  @override
  State<FihiranaScreen> createState() => _FihiranaScreenState();
}

class _FihiranaScreenState extends State<FihiranaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _categories = ['ffpm', 'fanampiny', 'antema'];
  final List<String> _tabLabels = ['Fihirana FFPM', 'Fanampiny', 'Antema'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<FihiranaCubit>().loadHymns(_categories[0]);
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
              Text("Fihirana sy Antema", style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildSearchBar(theme),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                labelStyle: theme.textTheme.titleMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                tabs: _tabLabels.map((label) => Tab(height: 28, text: label)).toList(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<FihiranaSearchCubit, FihiranaSearchState>(
                  builder: (context, searchState) {
                    if (searchState is FihiranaSearchLoading) return const Center(child: CircularProgressIndicator());
                    if (searchState is FihiranaSearchSuccess) return HymnListView(hymns: searchState.results, isSearchResult: true);
                    if (searchState is FihiranaSearchError) return Center(child: Text(searchState.message, style: const TextStyle(fontSize: 11)));
                    return BlocBuilder<FihiranaCubit, FihiranaState>(
                      builder: (context, state) {
                        if (state is FihiranaLoading) return const Center(child: CircularProgressIndicator());
                        if (state is FihiranaLoaded) return HymnListView(hymns: state.hymns, isSearchResult: false);
                        if (state is FihiranaError) return Center(child: Text(state.message, style: const TextStyle(fontSize: 11)));
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

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(Icons.search, size: 16)),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              decoration: InputDecoration(
                hintText: "Hikaroka hira (laharana, lohateny...)",
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (query) => context.read<FihiranaSearchCubit>().search(query),
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
    );
  }
}
