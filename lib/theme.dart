import 'package:material_ui/material_ui.dart';

/// Paleta de cores do Saborê.
///
/// A ideia visual é "cozinha de casa": tons quentes de terracota e
/// açafrão sobre um fundo creme, com um verde-oliva para destaques.
class AppColors {
  AppColors._();

  static const terracota = Color(0xFFB8492A);
  static const terracotaEscuro = Color(0xFF8A3219);
  static const acafrao = Color(0xFFE9A23B);
  static const oliva = Color(0xFF5E6B2F);
  static const creme = Color(0xFFFFF7EC);
  static const papel = Color(0xFFFFFFFF);
  static const tinta = Color(0xFF2B1D16); // texto principal
  static const tintaSuave = Color(0xFF6E5B50); // texto secundário
}

/// Tema global do app. Centralizar aqui evita repetir cores e
/// estilos em cada tela.
ThemeData buildSaboreTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.terracota,
    primary: AppColors.terracota,
    secondary: AppColors.acafrao,
    tertiary: AppColors.oliva,
    surface: AppColors.creme,
    onSurface: AppColors.tinta,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.creme,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: AppColors.tinta,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.tinta,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.tinta,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: AppColors.tinta),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: AppColors.tintaSuave,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.creme,
      foregroundColor: AppColors.tinta,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.papel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF0E2D0)),
      ),
    ),
  );
}
