import 'package:material_ui/material_ui.dart';

import 'pages/inicio_page.dart';
import 'services/receitas_service.dart';
import 'state/favoritos.dart';
import 'theme.dart';

void main() {
  runApp(const SaboreApp());
}

/// Widget raiz: define nome, tema, a primeira tela e os favoritos
/// compartilhados por todas as telas.
class SaboreApp extends StatefulWidget {
  /// [servico] pode ser trocado nos testes por um que usa dados falsos.
  const SaboreApp({super.key, this.servico});

  final ReceitasService? servico;

  @override
  State<SaboreApp> createState() => _SaboreAppState();
}

class _SaboreAppState extends State<SaboreApp> {
  // Uma única lista de favoritos para o app inteiro.
  final _favoritos = Favoritos();
  late final ReceitasService _servico = widget.servico ?? ReceitasService();

  @override
  void dispose() {
    _favoritos.dispose();
    _servico.fechar();
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
      home: InicioPage(servico: _servico),
    );
  }
}
