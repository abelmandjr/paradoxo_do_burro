import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tutorialPages = [
    {
      'title': 'O Paradoxo do Burro',
      'content':
          'Um burro faminto, equidistante de dois montes de feno, morre de fome por não conseguir decidir qual monte comer. Esse paradoxo ilustra a paralisia diante de escolhas igualmente atraentes.',
      'image': Icons.psychology,
    },
    {
      'title': 'Como o App Ajuda',
      'content':
          'Nosso app quantifica o impacto de cada decisão com base em valor monetário, tempo de impacto e peso emocional, calculando automaticamente a melhor opção.',
      'image': Icons.emoji_objects,
    },
    {
      'title': 'Fórmula do Impacto',
      'content':
          'Impacto = (Tempo de Impacto × Peso Emocional) / Valor\n\nExemplo: Comprar um curso caro (alto valor) com retorno longo (alto tempo) e alta satisfação (alto peso) pode ter impacto similar a um gasto pequeno com retorno imediato.',
      'image': Icons.calculate,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        actions: [
          TextButton(
            child: Text(
              _currentPage == _tutorialPages.length - 1 ? 'Concluir' : 'Pular',
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _tutorialPages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final page = _tutorialPages[index];
                return TutorialSlide(
                  title: page['title'],
                  content: page['content'],
                  icon: page['image'],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão "Anterior"
                if (_currentPage > 0)
                  TextButton(
                    onPressed:
                        () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                    child: const Text('Anterior'),
                  ),
                // Indicadores de página
                Row(
                  children: List.generate(
                    _tutorialPages.length,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage == i
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Botão "Próximo" ou "Concluir"
                TextButton(
                  onPressed: () {
                    if (_currentPage < _tutorialPages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    _currentPage == _tutorialPages.length - 1
                        ? 'Concluir'
                        : 'Próximo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para cada slide do tutorial
class TutorialSlide extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const TutorialSlide({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
