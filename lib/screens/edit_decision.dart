import 'package:flutter/material.dart';
import '../models/decision.dart';
import '../services/decision_service.dart';

class EditDecisionPage extends StatefulWidget {
  final Decision decision;

  const EditDecisionPage({super.key, required this.decision});

  @override
  State<EditDecisionPage> createState() => _EditDecisionPageState();
}

class _EditDecisionPageState extends State<EditDecisionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late TextEditingController _impactTimeController;
  late int _emotionalWeight;
  final DecisionService _decisionService = DecisionService();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.decision.description,
    );
    _valueController = TextEditingController(
      text: widget.decision.value.toString(),
    );
    _impactTimeController = TextEditingController(
      text: widget.decision.impactTime.toString(),
    );
    _emotionalWeight = widget.decision.emotionalWeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Decisão'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedDecision = Decision(
        id: widget.decision.id,
        userId: widget.decision.userId,
        description: _descriptionController.text,
        value: double.parse(_valueController.text),
        impactTime: int.parse(_impactTimeController.text),
        emotionalWeight: _emotionalWeight,
        createdAt: widget.decision.createdAt,
      );

      await _decisionService.updateDecision(updatedDecision);
      if (!mounted) return;
      Navigator.pop(context, updatedDecision); // Retorna a decisão atualizada
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    _impactTimeController.dispose();
    super.dispose();
  }
}
