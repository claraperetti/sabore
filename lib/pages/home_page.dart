import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Tela principal do Saborê.
///
/// Atividade 01: só layout e identidade visual. A pesquisa e a
/// navegação chegam nas próximas etapas.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          children: [
            const _Marca(),
            const SizedBox(height: 32),
            Text('Saborê', style: textos.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Receitas para o dia a dia, do jeito que você gosta.',
              style: textos.bodyLarge,
            ),
            const SizedBox(height: 32),
            const _Destaque(),
            const SizedBox(height: 32),
            Text('O que você encontra aqui', style: textos.titleLarge),
            const SizedBox(height: 16),
            const _Recurso(
              icone: Icons.search_rounded,
              titulo: 'Pesquise pelo nome',
              descricao: 'Digite o nome de um prato e encontre a receita.',
            ),
            const SizedBox(height: 12),
            const _Recurso(
              icone: Icons.menu_book_rounded,
              titulo: 'Ingredientes e preparo',
              descricao: 'Veja o que separar e o passo a passo da receita.',
            ),
            const SizedBox(height: 12),
            const _Recurso(
              icone: Icons.favorite_rounded,
              titulo: 'Guarde as favoritas',
              descricao: 'Marque as receitas que você quer fazer de novo.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Símbolo do app: um prato estilizado em terracota.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.terracota,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.restaurant_rounded,
          color: AppColors.creme,
          size: 34,
        ),
      ),
    );
  }
}

/// Faixa de destaque com uma frase de boas-vindas.
class _Destaque extends StatelessWidget {
  const _Destaque();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.terracota, AppColors.terracotaEscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'O que vamos cozinhar hoje?',
                  style: textos.titleLarge?.copyWith(color: AppColors.creme),
                ),
                const SizedBox(height: 6),
                Text(
                  'Centenas de receitas do mundo todo em um só lugar.',
                  style: textos.bodyMedium?.copyWith(
                    color: AppColors.creme.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.soup_kitchen_rounded,
            color: AppColors.acafrao,
            size: 48,
          ),
        ],
      ),
    );
  }
}

/// Cartão que descreve um recurso do app.
class _Recurso extends StatelessWidget {
  const _Recurso({
    required this.icone,
    required this.titulo,
    required this.descricao,
  });

  final IconData icone;
  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.acafrao.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: AppColors.terracota),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: textos.titleMedium),
                  const SizedBox(height: 2),
                  Text(descricao, style: textos.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
