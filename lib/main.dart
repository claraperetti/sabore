import 'package:material_ui/material_ui.dart';

import 'pages/home_page.dart';
import 'theme.dart';

void main() {
  runApp(const SaboreApp());
}

/// Widget raiz: define nome, tema e a primeira tela do app.
class SaboreApp extends StatelessWidget {
  const SaboreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saborê',
      debugShowCheckedModeBanner: false,
      theme: buildSaboreTheme(),
      home: const HomePage(),
    );
  }
}
