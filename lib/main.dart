import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/search_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';
import 'package:baiboly_apk/presentation/theme/app_theme.dart';
import 'package:baiboly_apk/presentation/screens/home_screen.dart';

void main() {
  // S'assurer que les liaisons Flutter sont initialisées
  WidgetsFlutterBinding.ensureInitialized();

  final bibleRepository = BibleRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BibleRepository>.value(value: bibleRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PreferencesCubit>(
            create: (context) => PreferencesCubit(),
          ),
          BlocProvider<BibleCubit>(
            create: (context) => BibleCubit(bibleRepository),
          ),
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(bibleRepository),
          ),
          BlocProvider<BookmarkCubit>(
            create: (context) => BookmarkCubit(bibleRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Baiboly Malagasy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(state.themeMode),
          home: const HomeScreen(),
        );
      },
    );
  }
}
