import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/decision.dart';

class DecisionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Salvar decisão
  Future<void> saveDecision(Decision decision) async {
    await _firestore
        .collection('users')
        .doc(decision.userId)
        .collection('decisions')
        .doc(decision.id)
        .set(decision.toMap());
  }

  // Listar decisões (com ordenação padrão por data)
  Stream<List<Decision>> getDecisions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('decisions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Decision.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Excluir decisão
  Future<void> deleteDecision(String userId, String decisionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('decisions')
        .doc(decisionId)
        .delete();
  }

  // (Opcional) Atualizar decisão
  Future<void> updateDecision(Decision decision) async {
    await _firestore
        .collection('users')
        .doc(decision.userId)
        .collection('decisions')
        .doc(decision.id)
        .update(decision.toMap());
  }
}
