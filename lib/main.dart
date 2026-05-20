import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';
import 'package:baiboly_apk/data/repositories/fihirana_repository.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_reader_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/search_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/fihirana_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/fihirana_search_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/hymn_detail_cubit.dart';
import 'package:baiboly_apk/presentation/theme/app_theme.dart';
import 'package:baiboly_apk/presentation/screens/home_screen.dart';

void main() {
  // S'assurer que les liaisons Flutter sont initialisées
  WidgetsFlutterBinding.ensureInitialized();

  final bibleRepository = BibleRepository();
  final fihiranaRepository = FihiranaRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BibleRepository>.value(value: bibleRepository),
        RepositoryProvider<FihiranaRepository>.value(value: fihiranaRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PreferencesCubit>(
            create: (context) => PreferencesCubit(),
          ),
          BlocProvider<BibleCubit>(
            create: (context) => BibleCubit(bibleRepository),
          ),
          BlocProvider<BibleReaderCubit>(
            create: (context) => BibleReaderCubit(bibleRepository),
          ),
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(bibleRepository),
          ),
          BlocProvider<BookmarkCubit>(
            create: (context) => BookmarkCubit(bibleRepository),
          ),
          BlocProvider<FihiranaCubit>(
            create: (context) => FihiranaCubit(fihiranaRepository),
          ),
          BlocProvider<FihiranaSearchCubit>(
            create: (context) => FihiranaSearchCubit(fihiranaRepository),
          ),
          BlocProvider<HymnDetailCubit>(
            create: (context) => HymnDetailCubit(fihiranaRepository),
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
          title: 'Baiboly FFPM',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(
            state.themeMode,
            Color(state.primaryColorValue),
          ),
          builder: (context, child) {
            final scale = state.fontSize / 18.0;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}
