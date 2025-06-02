import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/decision.dart';
import '../services/decision_service.dart';
import '../services/auth_service.dart';
import '../services/calculator.dart';
import '../services/export_service.dart';
import 'decision_detail.dart';
import 'compare_decisions.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DecisionService _decisionService = DecisionService();
  String _searchQuery = '';
  String _sortBy = 'data'; // 'data', 'impacto', 'valor'
  List<Decision> _selectedDecisions = [];

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Decisões'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () => _exportData(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Decision>>(
        stream: _decisionService.getDecisions(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Erro: ${snapshot.error}');
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final decisions = _applyFilters(snapshot.data!);
          return Column(
            children: [
              // Barra de busca e filtros
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged:
                          (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Selecionar Múltiplas'),
                          selected: _selectedDecisions.isNotEmpty,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDecisions = selected ? [] : [];
                            });
                          },
                        ),
                        if (_selectedDecisions.length == 2)
                          FilterChip(
                            label: const Text('Comparar Selecionadas'),
                            avatar: const Icon(Icons.compare),
                            onSelected: (_) => _navigateToCompare(context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Gráfico de impacto
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups:
                        decisions
                            .asMap()
                            .entries
                            .map(
                              (entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: DecisionCalculator.calculateImpact(
                                      entry.value,
                                    ),
                                    width: 16,
                                    color:
                                        _isSelected(entry.value)
                                            ? Colors.orange
                                            : Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget:
                              (value, meta) => Text(
                                'Dec. ${value.toInt() + 1}',
                                style: const TextStyle(fontSize: 10),
                              ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget:
                              (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Lista de decisões
              Expanded(
                child: ListView.builder(
                  itemCount: decisions.length,
                  itemBuilder: (context, index) {
                    final decision = decisions[index];
                    final isSelected = _isSelected(decision);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: isSelected ? Colors.orange.withOpacity(0.2) : null,
                      child: ListTile(
                        title: Text(decision.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valor: ${decision.value.toStringAsFixed(2)} MZN',
                            ),
                            Text(
                              'Impacto: ${DecisionCalculator.calculateImpact(decision).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd/MM/yy').format(decision.createdAt),
                            ),
                            if (_selectedDecisions.isNotEmpty)
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected ? Colors.orange : Colors.grey,
                              ),
                          ],
                        ),
                        onTap: () {
                          if (_selectedDecisions.isNotEmpty) {
                            setState(() {
                              isSelected
                                  ? _selectedDecisions.remove(decision)
                                  : _selectedDecisions.add(decision);
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        DecisionDetailPage(decision: decision),
                              ),
                            );
                          }
                        },
                        onLongPress:
                            () => setState(() {
                              isSelected
                                  ? _selectedDecisions.remove(decision)
                                  : _selectedDecisions.add(decision);
                            }),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isSelected(Decision decision) {
    return _selectedDecisions.any((d) => d.id == decision.id);
  }

  List<Decision> _applyFilters(List<Decision> decisions) {
    // Filtro de busca
    var filtered =
        decisions
            .where(
              (decision) => decision.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();

    // Ordenação
    switch (_sortBy) {
      case 'impacto':
        filtered.sort(
          (a, b) => DecisionCalculator.calculateImpact(
            b,
          ).compareTo(DecisionCalculator.calculateImpact(a)),
        );
        break;
      case 'valor':
        filtered.sort((a, b) => b.value.compareTo(a.value));
        break;
      default: // 'data'
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  Future<void> _showSortDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ordenar por'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: const Text('Data (recentes primeiro)'),
                  value: 'data',
                  groupValue: _sortBy,
                  onChanged:
                      (value) => setState(() {
                        _sortBy = value!;
                        Navigator.pop(context);
                      }),
                ),
                RadioListTile(
                  title: const Text('Maior Impacto'),
                  value: 'impacto',
                  groupValue: _sortBy,
                  onChanged:
                      (value) => setState(() {
                        _sortBy = value!;
                        Navigator.pop(context);
                      }),
                ),
                RadioListTile(
                  title: const Text('Maior Valor'),
                  value: 'valor',
                  groupValue: _sortBy,
                  onChanged:
                      (value) => setState(() {
                        _sortBy = value!;
                        Navigator.pop(context);
                      }),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final userId = AuthService.currentUser!.uid;
    final decisions = await _decisionService.getDecisions(userId).first;
    final csvData = ExportService.generateCSV(decisions);

    await Share.shareXFiles([
      XFile.fromData(
        Uint8List.fromList(csvData.codeUnits),
        name: 'decisoes.csv',
        mimeType: 'text/csv',
      ),
    ], text: 'Exportação de Decisões');
  }

  void _navigateToCompare(BuildContext context) {
    if (_selectedDecisions.length == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => CompareDecisionsPage(
                selectedDecision: _selectedDecisions[0],
                secondDecision: _selectedDecisions[1],
              ),
        ),
      );
      setState(() => _selectedDecisions = []);
    }
  }
}
