import 'package:material_ui/material_ui.dart';

import '../models/receita.dart';
import '../state/favoritos.dart';
import '../theme.dart';
import '../widgets/imagem_receita.dart';

/// Tela de detalhes de uma receita.
///
/// Decisão de projeto: os detalhes REAPROVEITAM o objeto que já veio
/// na listagem/pesquisa, sem chamar /recipes/{id}. A listagem já pede
/// todos os campos usados aqui (parâmetro `select`), então uma nova
/// chamada só gastaria internet e tempo, e não traria nada a mais.
class DetalhesPage extends StatelessWidget {
  const DetalhesPage({super.key, required this.receita});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final favoritos = FavoritosScope.of(context);
    final favorita = favoritos.contem(receita);

    return Scaffold(
      // CustomScrollView: tudo rola junto, então receitas longas
      // (muitos ingredientes ou passos) podem ser lidas inteiras.
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: AppColors.creme,
            leading: const _Circulo(child: BackButton()),
            actions: [
              _Circulo(
                child: IconButton(
                  key: const Key('botaoFavoritarDetalhes'),
                  tooltip: favorita
                      ? 'Remover dos favoritos'
                      : 'Adicionar aos favoritos',
                  onPressed: () => favoritos.alternar(receita),
                  icon: Icon(
                    favorita
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppColors.terracota,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ImagemReceita(
                url: receita.imagemUrl,
                raio: 0,
                tamanhoIcone: 72,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList.list(
              children: [
                Text(
                  receita.nome,
                  style: textos.displaySmall?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    ?receita.culinaria,
                    ?receita.dificuldade,
                    if (receita.avaliacaoTexto case final nota?) '★ $nota',
                  ].join('  •  '),
                  style: textos.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _Quadro(
                        valor: receita.tempoTotal != null
                            ? '${receita.tempoTotal} min'
                            : '—',
                        legenda: receita.tempoTotal != null
                            ? 'tempo total'
                            : 'tempo não informado',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Quadro(
                        valor: receita.porcoes?.toString() ?? '—',
                        legenda: receita.porcoes != null
                            ? 'porções'
                            : 'porções não informadas',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Quadro(
                        valor: favorita ? 'Salva' : 'Não salva',
                        legenda: 'nos favoritos',
                      ),
                    ),
                  ],
                ),
                if (receita.tempoPreparo != null ||
                    receita.tempoCozimento != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Preparo: ${_minutos(receita.tempoPreparo)}  •  '
                    'Cozimento: ${_minutos(receita.tempoCozimento)}',
                    style: textos.bodyMedium,
                  ),
                ],
                if (receita.tiposRefeicao.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tipo in receita.tiposRefeicao)
                        Chip(
                          label: Text(tipo),
                          avatar: const Icon(
                            Icons.restaurant_rounded,
                            size: 16,
                            color: AppColors.terracota,
                          ),
                          backgroundColor: AppColors.papel,
                          side: const BorderSide(color: Color(0xFFF0E2D0)),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                Text('Ingredientes', style: textos.titleLarge),
                const SizedBox(height: 8),
                if (receita.ingredientes.isEmpty)
                  Text('Ingredientes não informados.', style: textos.bodyMedium)
                else
                  for (final ingrediente in receita.ingredientes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 8, right: 12),
                            child: Icon(
                              Icons.circle,
                              size: 7,
                              color: AppColors.acafrao,
                            ),
                          ),
                          Expanded(
                            child: Text(ingrediente, style: textos.bodyLarge),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 28),
                Text('Modo de preparo', style: textos.titleLarge),
                const SizedBox(height: 12),
                if (receita.instrucoes.isEmpty)
                  Text(
                    'Modo de preparo não informado.',
                    style: textos.bodyMedium,
                  )
                else
                  for (final (indice, passo) in receita.instrucoes.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.terracota,
                            child: Text(
                              '${indice + 1}',
                              style: const TextStyle(
                                color: AppColors.creme,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(passo, style: textos.bodyLarge)),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _minutos(int? valor) =>
      valor == null ? 'não informado' : '$valor min';
}

/// Fundo circular claro para os botões ficarem visíveis sobre
/// qualquer imagem.
class _Circulo extends StatelessWidget {
  const _Circulo({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.creme.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

/// Quadro com um número em destaque e uma legenda.
class _Quadro extends StatelessWidget {
  const _Quadro({required this.valor, required this.legenda});

  final String valor;
  final String legenda;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.acafrao.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.terracotaEscuro,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            legenda,
            style: const TextStyle(fontSize: 12, color: AppColors.tintaSuave),
          ),
        ],
      ),
    );
  }
}
