# Saborê

Aplicativo mobile de receitas feito em Flutter. Com ele, você descobre receitas, pesquisa pelo nome, lê ingredientes e modo de preparo e guarda suas favoritas. Os dados vêm da API pública [DummyJSON Recipes](https://dummyjson.com/docs/recipes).

Projeto desenvolvido individualmente, em etapas:

| Etapa | Commit |
|---|---|
| Atividade 01: interface e identidade visual | `Primeira Parte - Definindo Layout` |
| Atividade 02: campo de pesquisa com validação | `Segunda Parte - Criando Campo de Pesquisa` |
| Atividade 03: telas de listagem, detalhes e favoritos | `Terceira Parte - Telas de Listagem, Detalhes e Favoritos` |
| Entrega final: integração com a API DummyJSON | (commit da entrega final) |

## Funcionalidades

| Requisito | Como o app atende |
|---|---|
| **RF01 Tela principal** | A aba Explorar mostra a identidade do app (logo, nome, faixa de destaque), o campo de pesquisa e a lista. O carregamento das receitas começa assim que o app abre. |
| **RF02 Listagem** | Lista rolável com imagem, nome, tempo total, dificuldade e avaliação. Se a imagem não existir, estiver carregando ou falhar, aparece um substituto no lugar. |
| **RF03 Pesquisa** | Pesquisa remota em `/recipes/search`. Espaços no início e no fim são removidos, e consultas vazias ou só com espaços são recusadas com uma mensagem explicando como corrigir. O botão **Limpar pesquisa** volta à listagem. |
| **RF04 Detalhes** | Imagem, culinária, dificuldade, avaliação, tempo total (e preparo/cozimento), porções, tipos de refeição, ingredientes e passos numerados. A tela inteira rola, então receitas longas podem ser lidas completas. |
| **RF05 Favoritos** | Coração no cartão e nos detalhes. Os favoritos ficam na memória durante a sessão, **sem duplicatas** (indexados pelo `id`), e aparecem na aba **Favoritos**, que mostra um contador. |
| **RF06 Carregamento** | Esqueleto de cartões com "Carregando receitas...". Durante uma busca, o botão fica desativado e respostas antigas são descartadas. |
| **RF07 Erros** | Falha de rede, tempo esgotado, status HTTP de erro e JSON incompatível viram mensagens em linguagem simples, com o botão **Tentar novamente**, que repete o último pedido. |
| **RF08 Ausência de resultados** | "Nenhum resultado" (busca sem correspondências, com **Alterar pesquisa** e **Ver todas as receitas**), erro de rede e "Nenhum favorito" são três telas diferentes. |
| **RF09 Navegação** | Abrir os detalhes empilha uma tela por cima da lista. Ao voltar, a pesquisa, os resultados e o texto do campo continuam lá. Trocar de aba também não perde nada. |

## Decisões de projeto

- **Detalhes sem nova chamada à API.** A listagem e a pesquisa já pedem, com o parâmetro `select`, todos os campos usados nos detalhes. Por isso a tela de detalhes reaproveita o objeto recebido em vez de chamar `/recipes/{id}`. Assim o app não gasta internet nem tempo à toa.
- **Validação dos dados recebidos** (`lib/models/receita.dart`):
  - `id` é obrigatório e precisa ser inteiro. Itens sem `id` válido são descartados, porque sem ele não há como identificar a receita nem evitar duplicatas.
  - `name` ausente ou inválido vira "Receita sem nome".
  - `ingredients`, `instructions` e `mealType` são lidos como listas de texto: itens que não são texto são ignorados e a ordem é preservada. Um `mealType` que chegue como texto único vira uma lista de um item.
  - `prepTimeMinutes` e `cookTimeMinutes` têm o tipo conferido. Ausência **não vira zero**: o tempo total só é calculado quando os dois existem, e a tela mostra "tempo não informado".
  - `servings` só aparece quando é pelo menos 1.
  - `rating` é lido como `num`, ou seja, aceita tanto `5` quanto `4.6`.
  - Se a resposta inteira tiver formato inesperado (por exemplo, `recipes` não é uma lista), o app mostra a tela de erro.
- **Carregamento inicial uma única vez.** Ele fica no `initState`, e não no `build`, para não recomeçar a cada reconstrução da tela. As abas usam `IndexedStack`, que mantém as duas vivas.
- **Consultas concorrentes.** Cada pedido recebe um número. Se a resposta de um pedido antigo chegar depois de um mais novo, ela é ignorada. Além disso, o botão de pesquisa fica desativado enquanto carrega.
- **Fonte única de verdade dos favoritos.** Há uma única instância de `Favoritos` (`ChangeNotifier`), disponibilizada a todas as telas por um `InheritedNotifier` (`FavoritosScope`), sem pacotes extras.

## Estrutura do código

```
lib/
├── main.dart                  # widget raiz: tema, favoritos e serviço
├── theme.dart                 # cores e estilos do Saborê
├── models/receita.dart        # modelo + leitura e validação do JSON
├── services/receitas_service.dart  # chamadas HTTP e tratamento de erros
├── state/favoritos.dart       # favoritos da sessão (sem duplicatas)
├── utils/validacao.dart       # validação do campo de pesquisa
├── pages/
│   ├── inicio_page.dart       # barra inferior: Explorar / Favoritos
│   ├── home_page.dart         # aba Explorar: pesquisa + listagem
│   ├── detalhes_page.dart     # detalhes da receita
│   └── favoritos_page.dart    # aba Favoritos
└── widgets/
    ├── cartao_receita.dart    # cartão usado na lista e nos favoritos
    └── imagem_receita.dart    # imagem com alternativa para falha
test/                          # testes de unidade e de widget (API falsa)
```

## Dependências

| Pacote | Para quê |
|---|---|
| `material_ui` ^1.1.0 | Componentes Material (padrão do Flutter 3.50) |
| `http` ^1.6.0 | Requisições à API DummyJSON |
| `cupertino_icons` ^1.0.8 | Ícones (padrão do template Flutter) |
| `flutter_test` (dev) | Testes automatizados |
| `flutter_lints` ^6.0.0 (dev) | Regras de análise de código |

## SDK utilizado

- Flutter **3.50.0** (canal stable)
- Dart **3.14.0**
- Testado no emulador Android **Medium Phone API 36** (Android 16)

## Como executar

Pré-requisitos: Flutter instalado (`flutter doctor` sem erros) e um emulador Android aberto ou um celular conectado, **com internet**.

```bash
git clone https://github.com/claraperetti/sabore.git
cd sabore
flutter pub get
flutter run
```

As receitas da API estão em inglês. Para pesquisar, use termos como `pizza`, `chicken` ou `salad`.

## Testes

```bash
flutter test
```

Os testes não dependem da internet: usam um cliente HTTP falso (`MockClient`) que imita as respostas da API, incluindo falhas de rede, erro de servidor e JSON inválido. Eles cobrem a validação dos dados, o serviço da API, os favoritos e as telas (carregamento, erro e nova tentativa, pesquisa, ausência de resultados, navegação e favoritos).
