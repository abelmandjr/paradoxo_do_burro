import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:paradoxo_do_burro/services/calculator.dart';
import '../models/decision.dart';

class ExportService {
  static String generateCSV(List<Decision> decisions) {
    final header = [
      'Descrição',
      'Valor (MZN)',
      'Tempo (dias)',
      'Peso',
      'Impacto',
      'Data',
    ];
    final rows =
        decisions
            .map(
              (decision) => [
                decision.description,
                decision.value.toStringAsFixed(2),
                decision.impactTime.toString(),
                decision.emotionalWeight.toString(),
                DecisionCalculator.calculateImpact(decision).toStringAsFixed(2),
                DateFormat('dd/MM/yyyy').format(decision.createdAt),
              ],
            )
            .toList();

    return const ListToCsvConverter().convert([header, ...rows]);
  }

  // TODO: Adicionar PDF export usando package 'pdf'
}
