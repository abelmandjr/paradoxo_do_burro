import 'package:paradoxo_do_burro/models/decision.dart';

class DecisionCalculator {
  // Fórmula: Impacto = (Tempo de Impacto × Peso Emocional) / Valor
  static double calculateImpact(Decision decision) {
    return (decision.impactTime * decision.emotionalWeight) / decision.value;
  }

  // Comparar duas decisões
  static Decision getBestDecision(List<Decision> decisions) {
    decisions.sort((a, b) => calculateImpact(b).compareTo(calculateImpact(a)));
    return decisions.first;
  }
}
