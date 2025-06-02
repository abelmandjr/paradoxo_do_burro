import 'package:flutter/material.dart';
import '../models/decision.dart';
import '../services/calculator.dart';

class CompareDecisionsPage extends StatefulWidget {
  final Decision selectedDecision;
  final Decision? secondDecision;

  const CompareDecisionsPage({
    super.key,
    required this.selectedDecision,
    this.secondDecision, // Torne-o obrigatório
  });

  @override
  State<CompareDecisionsPage> createState() => _CompareDecisionsPageState();
}

class _CompareDecisionsPageState extends State<CompareDecisionsPage> {
  Decision? _secondDecision;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparar Decisões')),
      body:
          _secondDecision == null
              ? _buildDecisionSelector()
              : _buildComparisonTable(),
    );
  }

  Widget _buildDecisionSelector() {
    // TODO: Listar decisões disponíveis para seleção
    return Center(
      child: ElevatedButton(
        onPressed:
            () => setState(
              () =>
                  _secondDecision = Decision(
                    userId: '',
                    description: 'Exemplo Comparação',
                    value: 500,
                    impactTime: 30,
                    emotionalWeight: 7,
                    createdAt: DateTime.now(),
                  ),
            ),
        child: const Text('Selecionar Decisão para Comparar'),
      ),
    );
  }

  Widget _buildComparisonTable() {
    final decision1 = widget.selectedDecision;
    final decision2 = _secondDecision!;
    final impact1 = DecisionCalculator.calculateImpact(decision1);
    final impact2 = DecisionCalculator.calculateImpact(decision2);

    return DataTable(
      columns: const [
        DataColumn(label: Text('Critério')),
        DataColumn(label: Text('Decisão 1')),
        DataColumn(label: Text('Decisão 2')),
      ],
      rows: [
        _buildDataRow(
          'Descrição',
          decision1.description,
          decision2.description,
        ),
        _buildDataRow(
          'Valor',
          '${decision1.value} MZN',
          '${decision2.value} MZN',
        ),
        _buildDataRow(
          'Tempo Impacto',
          '${decision1.impactTime} dias',
          '${decision2.impactTime} dias',
        ),
        _buildDataRow(
          'Peso Emocional',
          decision1.emotionalWeight.toString(),
          decision2.emotionalWeight.toString(),
        ),
        _buildDataRow(
          'Impacto Calculado',
          impact1.toStringAsFixed(2),
          impact2.toStringAsFixed(2),
          isBold: true,
          betterValue: impact1 > impact2 ? 1 : 2,
        ),
      ],
    );
  }

  DataRow _buildDataRow(
    String criterion,
    String value1,
    String value2, {
    bool isBold = false,
    int? betterValue,
  }) {
    return DataRow(
      cells: [
        DataCell(Text(criterion)),
        DataCell(
          Text(
            value1,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: betterValue == 1 ? Colors.green : null,
            ),
          ),
        ),
        DataCell(
          Text(
            value2,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: betterValue == 2 ? Colors.green : null,
            ),
          ),
        ),
      ],
    );
  }
}
