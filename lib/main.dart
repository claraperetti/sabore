import 'package:material_ui/material_ui.dart';

import 'pages/home_page.dart';
import 'state/favoritos.dart';
import 'theme.dart';

void main() {
  runApp(const SaboreApp());
}

/// Widget raiz: define nome, tema, a primeira tela e os favoritos
/// compartilhados por todas as telas.
class SaboreApp extends StatefulWidget {
  const SaboreApp({super.key});

  @override
  State<SaboreApp> createState() => _SaboreAppState();
}

class _SaboreAppState extends State<SaboreApp> {
  // Uma única lista de favoritos para o app inteiro.
  final _favoritos = Favoritos();

  @override
  void dispose() {
    _favoritos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saborê',
      debugShowCheckedModeBanner: false,
      theme: buildSaboreTheme(),
      // O builder coloca o FavoritosScope acima do Navigator, então
      // todas as telas abertas com push() enxergam os favoritos.
      builder: (context, child) =>
          FavoritosScope(favoritos: _favoritos, child: child!),
      home: const HomePage(),
    );
  }
}
