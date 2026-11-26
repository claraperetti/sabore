import 'package:material_ui/material_ui.dart';

import '../data/receitas_exemplo.dart';
import '../theme.dart';
import '../utils/validacao.dart';

/// Tela principal do Saborê.
///
/// Atividade 02: agora a tela tem estado (StatefulWidget), porque
/// precisa lembrar o termo pesquisado e os resultados.
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

  // Termo da última pesquisa válida. null = nenhuma pesquisa feita.
  String? _termoPesquisado;
  List<String> _resultados = [];
  // Depois da primeira tentativa, o erro é revalidado enquanto a
  // pessoa digita, e some assim que o texto fica válido.
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
      _resultados = buscarReceitasExemplo(termo);
    });
  }

  void _novaBusca() {
    _controller.clear();
    setState(() {
      _termoPesquisado = null;
      _resultados = [];
      _autoValidar = AutovalidateMode.disabled;
    });
    _foco.requestFocus();
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
    final textos = Theme.of(context).textTheme;
    final termo = _termoPesquisado;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          children: [
            const _Marca(),
            const SizedBox(height: 24),
            Text('Saborê', style: textos.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Receitas para o dia a dia, do jeito que você gosta.',
              style: textos.bodyLarge,
            ),
            const SizedBox(height: 24),
            const _Destaque(),
            const SizedBox(height: 20),
            _FormularioPesquisa(
              formKey: _formKey,
              controller: _controller,
              foco: _foco,
              autoValidar: _autoValidar,
              aoPesquisar: _pesquisar,
            ),
            const SizedBox(height: 28),
            if (termo == null) ...[
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
            ] else
              _ResultadoPesquisa(
                termo: termo,
                resultados: _resultados,
                aoNovaBusca: _novaBusca,
              ),
          ],
        ),
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

/// Mostra o termo pesquisado, os resultados provisórios e o botão
/// para fazer outra busca.
class _ResultadoPesquisa extends StatelessWidget {
  const _ResultadoPesquisa({
    required this.termo,
    required this.resultados,
    required this.aoNovaBusca,
  });

  final String termo;
  final List<String> resultados;
  final VoidCallback aoNovaBusca;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final quantidade = resultados.length;
    final resumo = switch (quantidade) {
      0 => 'Nenhuma receita encontrada.',
      1 => '1 receita encontrada.',
      _ => '$quantidade receitas encontradas.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Você pesquisou: “$termo”', style: textos.titleLarge),
        const SizedBox(height: 4),
        Text(resumo, style: textos.bodyMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.acafrao.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Resultados de exemplo. A busca real chega na versão final.',
            style: textos.bodyMedium?.copyWith(color: AppColors.tinta),
          ),
        ),
        const SizedBox(height: 16),
        if (quantidade == 0)
          Text(
            'Tente outro nome, como “bolo” ou “frango”.',
            style: textos.bodyLarge,
          )
        else
          for (final nome in resultados) ...[
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.terracota,
                ),
                title: Text(nome, style: textos.titleMedium),
              ),
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          key: const Key('botaoNovaBusca'),
          onPressed: aoNovaBusca,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Fazer nova busca'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.terracota,
            side: const BorderSide(color: AppColors.terracota),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
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
