import 'package:material_ui/material_ui.dart';

import '../models/receita.dart';
import '../services/receitas_service.dart';
import '../theme.dart';
import '../utils/validacao.dart';
import '../widgets/cartao_receita.dart';
import 'detalhes_page.dart';

/// Em que situação está o carregamento da lista.
enum _Situacao { carregando, pronta, erro }

/// Aba "Explorar": identidade do app, pesquisa e listagem.
///
/// Ao abrir, carrega todas as receitas da API. A pesquisa consulta
/// o endpoint remoto /recipes/search. Esta tela continua viva por
/// baixo dos detalhes e da aba Favoritos, então a pesquisa não se
/// perde ao voltar.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.servico});

  final ReceitasService servico;

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
  // Depois da primeira tentativa inválida, o erro é revalidado
  // enquanto a pessoa digita e some assim que o texto fica válido.
  AutovalidateMode _autoValidar = AutovalidateMode.disabled;

  // Termo da última pesquisa válida. null = mostrando todas.
  String? _termoPesquisado;
  _Situacao _situacao = _Situacao.carregando;
  List<Receita> _receitas = [];
  String _mensagemErro = '';

  // Lista completa guardada depois do primeiro carregamento, para
  // "Limpar pesquisa" não precisar baixar tudo de novo.
  List<Receita>? _todas;
  // Lembra o último pedido, para o botão "Tentar novamente".
  VoidCallback _repetirUltimoPedido = () {};
  // Cada pedido ganha um número. Se chegar a resposta de um pedido
  // antigo depois de um mais novo, ela é ignorada (consultas
  // concorrentes nunca bagunçam a tela).
  int _pedidoAtual = 0;

  bool get _carregando => _situacao == _Situacao.carregando;

  @override
  void initState() {
    super.initState();
    // O carregamento inicial fica no initState, que roda UMA vez.
    // Se ficasse no build, recomeçaria a cada reconstrução da tela.
    _carregarTodas();
  }

  void _carregarTodas() {
    final todas = _todas;
    if (todas != null) {
      setState(() {
        _receitas = todas;
        _situacao = _Situacao.pronta;
      });
      return;
    }
    _executar(widget.servico.listarTodas, guardarComoTodas: true);
  }

  Future<void> _executar(
    Future<List<Receita>> Function() pedido, {
    bool guardarComoTodas = false,
  }) async {
    _repetirUltimoPedido = () =>
        _executar(pedido, guardarComoTodas: guardarComoTodas);
    final numero = ++_pedidoAtual;
    setState(() => _situacao = _Situacao.carregando);

    try {
      final receitas = await pedido();
      if (!mounted || numero != _pedidoAtual) return;
      setState(() {
        _receitas = receitas;
        if (guardarComoTodas) _todas = receitas;
        _situacao = _Situacao.pronta;
      });
    } on ErroReceitas catch (erro) {
      if (!mounted || numero != _pedidoAtual) return;
      setState(() {
        _mensagemErro = erro.mensagem;
        _situacao = _Situacao.erro;
      });
    }
  }

  void _pesquisar() {
    // Enquanto uma busca está em andamento, novos toques são
    // ignorados (o botão também fica desativado).
    if (_carregando) return;

    final valido = _formKey.currentState!.validate();
    if (!valido) {
      setState(() => _autoValidar = AutovalidateMode.onUserInteraction);
      _foco.requestFocus();
      return;
    }

    final termo = _controller.text.trim(); // remove espaços externos
    FocusScope.of(context).unfocus(); // fecha o teclado
    setState(() => _termoPesquisado = termo);
    _executar(() => widget.servico.buscarPorNome(termo));
  }

  /// "Limpar pesquisa" / "Ver todas as receitas": volta à listagem.
  void _limparPesquisa() {
    _controller.clear();
    setState(() {
      _termoPesquisado = null;
      _autoValidar = AutovalidateMode.disabled;
    });
    _carregarTodas();
  }

  /// "Alterar pesquisa": volta o cursor ao campo, com o texto
  /// selecionado para ser trocado.
  void _alterarPesquisa() {
    _foco.requestFocus();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  void _abrirDetalhes(Receita receita) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetalhesPage(receita: receita)),
    );
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
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList.list(
              children: [
                const _Cabecalho(),
                const SizedBox(height: 20),
                const _Destaque(),
                const SizedBox(height: 16),
                _FormularioPesquisa(
                  formKey: _formKey,
                  controller: _controller,
                  foco: _foco,
                  autoValidar: _autoValidar,
                  carregando: _carregando,
                  aoPesquisar: _pesquisar,
                ),
                const SizedBox(height: 24),
                _TituloLista(
                  termo: _termoPesquisado,
                  quantidade: _situacao == _Situacao.pronta
                      ? _receitas.length
                      : null,
                  aoLimpar: _limparPesquisa,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          ..._conteudo(),
        ],
      ),
    );
  }

  /// O que aparece abaixo do título, conforme a situação.
  List<Widget> _conteudo() {
    switch (_situacao) {
      case _Situacao.carregando:
        return const [SliverToBoxAdapter(child: _Carregando())];
      case _Situacao.erro:
        return [
          SliverToBoxAdapter(
            child: _ErroCarregamento(
              mensagem: _mensagemErro,
              aoTentarNovamente: _repetirUltimoPedido,
            ),
          ),
        ];
      case _Situacao.pronta when _receitas.isEmpty:
        return [
          SliverToBoxAdapter(
            child: _SemResultados(
              termo: _termoPesquisado,
              aoAlterarPesquisa: _alterarPesquisa,
              aoVerTodas: _limparPesquisa,
            ),
          ),
        ];
      case _Situacao.pronta:
        return [
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
        ];
    }
  }
}

/// Logo e nome do app.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saborê', style: textos.displaySmall?.copyWith(fontSize: 28)),
            Text('Receitas para o dia a dia', style: textos.bodyMedium),
          ],
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
                  'Pesquise uma receita pelo nome ou explore a lista abaixo.',
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
    required this.carregando,
    required this.aoPesquisar,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final FocusNode foco;
  final AutovalidateMode autoValidar;
  final bool carregando;
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
                  hintText: 'Ex.: pizza, chicken, salad',
                  helperText: 'Você pode buscar por parte do nome.',
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
                // null desativa o botão enquanto carrega.
                onPressed: carregando ? null : aoPesquisar,
                icon: carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
                label: Text(carregando ? 'Carregando...' : 'Pesquisar'),
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

/// Título da lista: "Receitas disponíveis" ou os resultados da
/// pesquisa, com o botão para limpar a pesquisa.
class _TituloLista extends StatelessWidget {
  const _TituloLista({
    required this.termo,
    required this.quantidade,
    required this.aoLimpar,
  });

  final String? termo;
  final int? quantidade; // null = carregando ou com erro
  final VoidCallback aoLimpar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final termo = this.termo;
    final quantidade = this.quantidade;

    if (termo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Receitas disponíveis', style: textos.titleLarge),
          const SizedBox(height: 4),
          Text(
            quantidade == null
                ? 'Selecione uma receita para ver o preparo.'
                : '$quantidade receitas. Toque em uma para ver o preparo.',
            style: textos.bodyMedium,
          ),
        ],
      );
    }

    final resumo = switch (quantidade) {
      null => 'Buscando...',
      0 => 'Nenhuma receita encontrada.',
      1 => '1 receita encontrada.',
      _ => '$quantidade receitas encontradas.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resultados para “$termo”', style: textos.titleLarge),
        const SizedBox(height: 4),
        Text(resumo, style: textos.bodyMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('botaoLimparPesquisa'),
          onPressed: aoLimpar,
          icon: const Icon(Icons.close_rounded),
          label: const Text('Limpar pesquisa'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.terracota,
            side: const BorderSide(color: AppColors.terracota),
          ),
        ),
      ],
    );
  }
}

/// Esqueleto de cartões enquanto as receitas carregam.
class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) {
    const cinza = Color(0xFFEDE3D6);

    Widget barra(double largura) => Container(
      width: largura,
      height: 12,
      decoration: BoxDecoration(
        color: cinza,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Padding(
      key: const Key('carregando'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: cinza,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          barra(150),
                          const SizedBox(height: 10),
                          barra(110),
                          const SizedBox(height: 10),
                          barra(70),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text('Carregando receitas...'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mensagem de erro com botão para tentar de novo.
class _ErroCarregamento extends StatelessWidget {
  const _ErroCarregamento({
    required this.mensagem,
    required this.aoTentarNovamente,
  });

  final String mensagem;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Column(
        key: const Key('erroCarregamento'),
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.acafrao.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.terracota,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar as receitas.',
            style: textos.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(mensagem, style: textos.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('botaoTentarNovamente'),
            onPressed: aoTentarNovamente,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pesquisa sem resultados. É diferente do erro de rede (a API
/// respondeu certo, só não achou nada) e dos favoritos vazios.
class _SemResultados extends StatelessWidget {
  const _SemResultados({
    required this.termo,
    required this.aoAlterarPesquisa,
    required this.aoVerTodas,
  });

  final String? termo;
  final VoidCallback aoAlterarPesquisa;
  final VoidCallback aoVerTodas;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final termo = this.termo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Column(
        key: const Key('semResultados'),
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.acafrao.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.terracota,
            ),
          ),
          const SizedBox(height: 16),
          Text('Nenhum resultado', style: textos.titleLarge),
          const SizedBox(height: 8),
          Text(
            termo == null
                ? 'Não há receitas disponíveis no momento.'
                : 'Não encontramos receitas para “$termo”. As receitas '
                      'estão em inglês: tente outro termo, como “pizza” '
                      'ou “chicken”.',
            style: textos.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (termo != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('botaoAlterarPesquisa'),
              onPressed: aoAlterarPesquisa,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Alterar pesquisa'),
            ),
            TextButton(
              key: const Key('botaoVerTodas'),
              onPressed: aoVerTodas,
              child: const Text('Ver todas as receitas'),
            ),
          ],
        ],
      ),
    );
  }
}
