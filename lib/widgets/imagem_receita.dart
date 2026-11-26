import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Imagem de uma receita com alternativa para quando ela não existe,
/// ainda está carregando ou falha ao carregar.
class ImagemReceita extends StatelessWidget {
  const ImagemReceita({
    super.key,
    required this.url,
    this.largura,
    this.altura,
    this.raio = 12,
    this.tamanhoIcone = 32,
  });

  final String? url;
  final double? largura;
  final double? altura;
  final double raio;
  final double tamanhoIcone;

  @override
  Widget build(BuildContext context) {
    final endereco = url;

    final Widget conteudo;
    if (endereco == null || endereco.isEmpty) {
      conteudo = _Substituto(
        icone: Icons.restaurant_rounded,
        tamanhoIcone: tamanhoIcone,
        descricao: 'Receita sem imagem',
      );
    } else {
      conteudo = Image.network(
        endereco,
        width: largura,
        height: altura,
        fit: BoxFit.cover,
        // Enquanto baixa, mostra o fundo com um indicador.
        loadingBuilder: (context, filho, progresso) {
          if (progresso == null) return filho;
          return _Substituto(
            tamanhoIcone: tamanhoIcone,
            descricao: 'Carregando imagem',
            carregando: true,
          );
        },
        // Se der erro (sem internet, link quebrado...), mostra o
        // substituto no lugar da imagem.
        errorBuilder: (context, erro, pilha) => _Substituto(
          icone: Icons.no_photography_outlined,
          tamanhoIcone: tamanhoIcone,
          descricao: 'Imagem indisponível',
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: SizedBox(width: largura, height: altura, child: conteudo),
    );
  }
}

class _Substituto extends StatelessWidget {
  const _Substituto({
    required this.tamanhoIcone,
    required this.descricao,
    this.icone = Icons.restaurant_rounded,
    this.carregando = false,
  });

  final IconData icone;
  final double tamanhoIcone;
  final String descricao;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: descricao,
      child: ColoredBox(
        color: AppColors.acafrao.withValues(alpha: 0.18),
        child: Center(
          child: carregando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(icone, size: tamanhoIcone, color: AppColors.terracota),
        ),
      ),
    );
  }
}
