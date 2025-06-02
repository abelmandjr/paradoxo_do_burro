import 'package:flutter/material.dart';
import '../models/decision.dart';
import '../services/decision_service.dart';
import '../services/auth_service.dart';

class AddDecisionPage extends StatefulWidget {
  const AddDecisionPage({super.key});

  @override
  State<AddDecisionPage> createState() => _AddDecisionPageState();
}

class _AddDecisionPageState extends State<AddDecisionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _impactTimeController = TextEditingController();
  int _emotionalWeight = 5;
  final DecisionService _decisionService = DecisionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Decisão')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Valor (MZN)'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _impactTimeController,
                decoration: const InputDecoration(
                  labelText: 'Tempo de Impacto (dias)',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              Slider(
                value: _emotionalWeight.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: 'Peso Emocional: $_emotionalWeight',
                onChanged:
                    (value) => setState(() => _emotionalWeight = value.toInt()),
              ),
              ElevatedButton(
                onPressed: _saveDecision,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveDecision() async {
    if (_formKey.currentState!.validate()) {
      final decision = Decision(
        userId: AuthService.currentUser!.uid,
        description: _descriptionController.text,
        value: double.parse(_valueController.text),
        impactTime: int.parse(_impactTimeController.text),
        emotionalWeight: _emotionalWeight,
        createdAt: DateTime.now(),
        // O ID é gerado automaticamente pelo modelo Decision
      );
      await _decisionService.saveDecision(decision);
      Navigator.pop(context);
    }
  }
}
