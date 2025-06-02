import 'package:flutter/material.dart';
import 'package:paradoxo_do_burro/screens/compare_decisions.dart';
import 'package:paradoxo_do_burro/screens/edit_decision.dart';
import '../models/decision.dart';
import '../services/calculator.dart';
import '../services/decision_service.dart';

final DecisionService _decisionService = DecisionService();

class DecisionDetailPage extends StatelessWidget {
  final Decision decision;

  const DecisionDetailPage({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final impact = DecisionCalculator.calculateImpact(decision);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Decisão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              decision.description,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Valor', '${decision.value} MZN'),
            _buildDetailRow('Tempo de Impacto', '${decision.impactTime} dias'),
            _buildDetailRow('Peso Emocional', '${decision.emotionalWeight}/10'),
            const Divider(height: 30),
            Text(
              'Fórmula de Impacto:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              '(Tempo × Peso) / Valor = Impacto',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            Text(
              '(${decision.impactTime} × ${decision.emotionalWeight}) / ${decision.value} = ${impact.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.compare),
              label: const Text('Comparar com outra decisão'),
              onPressed: () => _navigateToCompare(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  // No método _showEditDialog:
  void _showEditDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditDecisionPage(decision: decision)),
    ).then((updatedDecision) {
      if (updatedDecision != null) {
        // Atualize a UI se necessário
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Decisão atualizada!')));
      }
    });
  }

  void _navigateToCompare(BuildContext context) {
    // Primeiro navega para uma tela de seleção
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(title: const Text('Selecione para comparar')),
              body: FutureBuilder<List<Decision>>(
                future: _decisionService.getDecisions(decision.userId).first,
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();

                  final otherDecisions =
                      snapshot.data!.where((d) => d.id != decision.id).toList();

                  return ListView.builder(
                    itemCount: otherDecisions.length,
                    itemBuilder: (context, index) {
                      final otherDecision = otherDecisions[index];
                      return ListTile(
                        title: Text(otherDecision.description),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => CompareDecisionsPage(
                                    selectedDecision: decision,
                                    secondDecision: otherDecision,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
      ),
    );
  }
}
