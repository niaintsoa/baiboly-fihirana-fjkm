import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';

class ColorPickerWidget extends StatelessWidget {
  const ColorPickerWidget({super.key});

  static const List<Color> availableColors = [
    Color(0xFF8B2635), // Bourgogne
    Color(0xFF2E7D32), // Vert émeraude
    Color(0xFF1976D2), // Bleu royal
    Color(0xFF6A1B9A), // Violet profond
    Color(0xFFD84315), // Orange ambré
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: availableColors.map((color) {
            final isSelected = state.primaryColorValue == color.value;

            return GestureDetector(
              onTap: () {
                context.read<PreferencesCubit>().setPrimaryColor(color.value);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
