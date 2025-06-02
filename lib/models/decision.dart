import 'package:uuid/uuid.dart'; // Adicione no pubspec.yaml: uuid: ^3.0.7

class Decision {
  final String id;
  final String userId;
  final String description;
  final double value;
  final int impactTime;
  final int emotionalWeight;
  final DateTime createdAt;

  Decision({
    String? id, // ID opcional
    required this.userId,
    required this.description,
    required this.value,
    required this.impactTime,
    this.emotionalWeight = 5,
    required this.createdAt,
  }) : id = id ?? const Uuid().v4(); // Gera um UUID se o ID for nulo

  // Converter para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'description': description,
      'value': value,
      'impactTime': impactTime,
      'emotionalWeight': emotionalWeight,
      'createdAt': createdAt,
    };
  }

  // Converter do Firestore
  factory Decision.fromMap(Map<String, dynamic> map, String id) {
    return Decision(
      id: id,
      userId: map['userId'],
      description: map['description'],
      value: map['value'].toDouble(),
      impactTime: map['impactTime'],
      emotionalWeight: map['emotionalWeight'],
      createdAt: map['createdAt'].toDate(),
    );
  }
}
