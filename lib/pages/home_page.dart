import 'package:material_ui/material_ui.dart';

import '../data/receitas_exemplo.dart';
import '../models/receita.dart';
import '../state/favoritos.dart';
import '../theme.dart';
import '../utils/validacao.dart';
import '../widgets/cartao_receita.dart';
import 'detalhes_page.dart';
import 'favoritos_page.dart';

/// Tela principal: pesquisa + listagem de receitas.
///
/// Atividade 03: ao abrir, mostra todas as receitas (provisórias).
/// Tocar numa receita abre os detalhes; o coração no topo abre os
/// favoritos. Como esta tela continua viva por baixo enquanto as
/// outras estão abertas, a pesquisa não se perde ao voltar.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // A chave do formulário permite chamar validate() no campo.
  final _formKey = GlobalKey<FormState>();
  // O controller lê e limpa o texto do campo.
  final _controller = TextEditingController();
  // O focusNode permite colocar o cursor de volta no campo.
  final _foco = FocusNode();

  // Termo da última pesquisa válida. null = mostrando todas.
  String? _termoPesquisado;
  List<Receita> _receitas = receitasExemplo;
  // Depois da primeira tentativa inválida, o erro é revalidado
  // enquanto a pessoa digita e some assim que o texto fica válido.
  AutovalidateMode _autoValidar = AutovalidateMode.disabled;

  void _pesquisar() {
    final valido = _formKey.currentState!.validate();
    if (!valido) {
      setState(() => _autoValidar = AutovalidateMode.onUserInteraction);
      _foco.requestFocus();
      return;
    }

    final termo = _controller.text.trim();
    FocusScope.of(context).unfocus(); // fecha o teclado
    setState(() {
      _termoPesquisado = termo;
      _receitas = buscarReceitasExemplo(termo);
    });
  }

  void _novaBusca() {
    _controller.clear();
    setState(() {
      _termoPesquisado = null;
      _receitas = receitasExemplo;
      _autoValidar = AutovalidateMode.disabled;
    });
    _foco.requestFocus();
  }

  void _abrirDetalhes(Receita receita) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetalhesPage(receita: receita)),
    );
  }

  void _abrirFavoritos() {
    FocusScope.of(context).unfocus();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const FavoritosPage()));
  }

  @override
  void dispose() {
    // Controllers e focusNodes precisam ser descartados para não
    // vazar memória.
    _controller.dispose();
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quantidadeFavoritas = FavoritosScope.of(context).quantidade;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList.list(
                children: [
                  _Cabecalho(
                    quantidadeFavoritas: quantidadeFavoritas,
                    aoAbrirFavoritos: _abrirFavoritos,
                  ),
                  const SizedBox(height: 20),
                  const _Destaque(),
                  const SizedBox(height: 16),
                  _FormularioPesquisa(
                    formKey: _formKey,
                    controller: _controller,
                    foco: _foco,
                    autoValidar: _autoValidar,
                    aoPesquisar: _pesquisar,
                  ),
                  const SizedBox(height: 24),
                  _TituloLista(
                    termo: _termoPesquisado,
                    quantidade: _receitas.length,
                    aoNovaBusca: _novaBusca,
                  ),
                  const SizedBox(height: 12),
                  const _AvisoProvisorio(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (_receitas.isEmpty)
              SliverToBoxAdapter(
                child: _SemResultados(termo: _termoPesquisado ?? ''),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.separated(
                  itemCount: _receitas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => CartaoReceita(
                    receita: _receitas[i],
                    aoTocar: () => _abrirDetalhes(_receitas[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Logo, nome do app e botão de favoritos com contador.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.quantidadeFavoritas,
    required this.aoAbrirFavoritos,
  });

  final int quantidadeFavoritas;
  final VoidCallback aoAbrirFavoritos;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.terracota,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: AppColors.creme,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saborê',
                style: textos.displaySmall?.copyWith(fontSize: 28),
              ),
              Text('Receitas para o dia a dia', style: textos.bodyMedium),
            ],
          ),
        ),
        IconButton.filledTonal(
          key: const Key('botaoFavoritos'),
          tooltip: 'Minhas favoritas',
          onPressed: aoAbrirFavoritos,
          icon: Badge(
            isLabelVisible: quantidadeFavoritas > 0,
            label: Text('$quantidadeFavoritas'),
            child: const Icon(Icons.favorite_rounded),
          ),
        ),
      ],
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

/// Campo rotulado + botão de busca.
class _FormularioPesquisa extends StatelessWidget {
  const _FormularioPesquisa({
    required this.formKey,
    required this.controller,
    required this.foco,
    required this.autoValidar,
    required this.aoPesquisar,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final FocusNode foco;
  final AutovalidateMode autoValidar;
  final VoidCallback aoPesquisar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          autovalidateMode: autoValidar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('campoPesquisa'),
                controller: controller,
                focusNode: foco,
                validator: validarTermoPesquisa,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => aoPesquisar(),
                decoration: InputDecoration(
                  labelText: 'Nome da receita',
                  hintText: 'Ex.: bolo de cenoura',
                  prefixIcon: const Icon(Icons.search_rounded),
                  errorMaxLines: 3,
                  filled: true,
                  fillColor: AppColors.creme,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('botaoPesquisar'),
                onPressed: aoPesquisar,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Pesquisar'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Título da lista: "Todas as receitas" ou o termo pesquisado,
/// com o botão para fazer nova busca.
class _TituloLista extends StatelessWidget {
  const _TituloLista({
    required this.termo,
    required this.quantidade,
    required this.aoNovaBusca,
  });

  final String? termo;
  final int quantidade;
  final VoidCallback aoNovaBusca;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final termo = this.termo;

    if (termo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Todas as receitas', style: textos.titleLarge),
          const SizedBox(height: 4),
          Text('$quantidade receitas para explorar.', style: textos.bodyMedium),
        ],
      );
    }

    final resumo = switch (quantidade) {
      0 => 'Nenhuma receita encontrada.',
      1 => '1 receita encontrada.',
      _ => '$quantidade receitas encontradas.',
    };

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Você pesquisou: “$termo”', style: textos.titleLarge),
              const SizedBox(height: 4),
              Text(resumo, style: textos.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          key: const Key('botaoNovaBusca'),
          onPressed: aoNovaBusca,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Nova busca'),
        ),
      ],
    );
  }
}

/// Aviso de que os dados ainda são de exemplo.
class _AvisoProvisorio extends StatelessWidget {
  const _AvisoProvisorio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.acafrao.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Receitas de exemplo. As receitas reais chegam na versão final.',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.tinta),
      ),
    );
  }
}

/// Mensagem para pesquisa sem resultados.
class _SemResultados extends StatelessWidget {
  const _SemResultados({required this.termo});

  final String termo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        key: const Key('semResultados'),
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.terracota,
          ),
          const SizedBox(height: 12),
          Text('Nenhuma receita encontrada', style: textos.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Não achamos receitas com “$termo”. Confira a grafia ou '
            'tente outro nome, como “bolo” ou “frango”.',
            style: textos.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
