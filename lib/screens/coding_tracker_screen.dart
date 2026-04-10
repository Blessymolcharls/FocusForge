import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/coding_progress_model.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class CodingTrackerScreen extends StatefulWidget {
  const CodingTrackerScreen({super.key});

  @override
  State<CodingTrackerScreen> createState() => _CodingTrackerScreenState();
}

class _CodingTrackerScreenState extends State<CodingTrackerScreen> {
  List<CodingProgressModel> _platforms = [];

  final Map<String, Color> _platformColors = {
    'LeetCode': const Color(0xFFFFA116),
    'CodeChef': const Color(0xFF724C2F),
    'HackerRank': const Color(0xFF1BA94C),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _platforms = StorageService.getAllCodingProgress();
    });
  }

  int get _totalSolved =>
      _platforms.fold(0, (sum, p) => sum + p.problemsSolved);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Coding Tracker'),
        backgroundColor: AppTheme.surface,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _buildTotalCard(),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Platform Progress'),
            const SizedBox(height: 12),
            ..._platforms.map((p) => _buildPlatformCard(p)),
            const SizedBox(height: 20),
            if (_platforms.isNotEmpty) _buildWeeklyChart(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUpdateDialog(null),
        backgroundColor: AppTheme.codingColor,
        icon: const Icon(Icons.add),
        label: const Text('Log Progress'),
      ),
    );
  }

  Widget _buildTotalCard() {
    return GradientCard(
      colors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Problems Solved',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalSolved',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'across all platforms',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.terminal, color: Colors.white30, size: 60),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(CodingProgressModel p) {
    final color = _platformColors[p.platform] ?? AppTheme.codingColor;
    final dailySolvedToday =
        p.weeklyHistory.isNotEmpty ? p.weeklyHistory.last : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _platformIcon(p.platform, color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.platform,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(
                      '${p.problemsSolved} / ${p.totalGoal} solved',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                onPressed: () => _showUpdateDialog(p),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBarCard(
            label: 'Overall Progress',
            progress: p.progressPercent,
            color: color,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statChip('Today', '$dailySolvedToday / ${p.dailyGoal}', color),
              const SizedBox(width: 10),
              _statChip('Daily Goal', '${p.dailyGoal} problems', AppTheme.primary),
              const SizedBox(width: 10),
              _statChip('+XP', '+20 XP', Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _platformIcon(String platform, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.code, color: color, size: 24),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Activity',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 6,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= days.length) return const SizedBox.shrink();
                        return Text(days[i],
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(7, (dayIndex) {
                  double total = 0;
                  for (final p in _platforms) {
                    if (dayIndex < p.weeklyHistory.length) {
                      total += p.weeklyHistory[dayIndex];
                    }
                  }
                  return BarChartGroupData(
                    x: dayIndex,
                    barRods: [
                      BarChartRodData(
                        toY: total,
                        color: AppTheme.primary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Update Progress Dialog ───────────────────────────────────────────────────

  void _showUpdateDialog(CodingProgressModel? existing) {
    final platforms = ['LeetCode', 'CodeChef', 'HackerRank'];
    String platform = existing?.platform ?? 'LeetCode';
    final solvedCtrl = TextEditingController(
        text: existing != null ? '${existing.problemsSolved}' : '');
    final dailyGoalCtrl = TextEditingController(
        text: existing != null ? '${existing.dailyGoal}' : '2');
    final totalGoalCtrl = TextEditingController(
        text: existing != null ? '${existing.totalGoal}' : '100');
    final todaySolvedCtrl = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(existing == null ? 'Add Platform' : 'Update Progress',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (existing == null) ...[
                    const Text('Platform', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: platforms.map((pl) {
                        final sel = pl == platform;
                        final col = _platformColors[pl] ?? AppTheme.primary;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setS(() => platform = pl),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: sel ? col : AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: col.withAlpha(120)),
                              ),
                              child: Text(pl,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: sel ? Colors.white : col,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: existing == null ? solvedCtrl : todaySolvedCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: existing == null
                          ? 'Total Problems Solved'
                          : 'Problems Solved Today',
                      prefixIcon: const Icon(Icons.add_task, color: AppTheme.primary),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Enter a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dailyGoalCtrl,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Daily Goal'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: totalGoalCtrl,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Total Goal'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);

                        if (existing == null) {
                          final model = CodingProgressModel(
                            id: StorageService.generateId(),
                            platform: platform,
                            problemsSolved: int.parse(solvedCtrl.text),
                            dailyGoal: int.parse(dailyGoalCtrl.text),
                            totalGoal: int.parse(totalGoalCtrl.text),
                            lastUpdated: DateTime.now(),
                          );
                          await StorageService.addCodingProgress(model);
                        } else {
                          final todaySolved = int.parse(todaySolvedCtrl.text);
                          existing.problemsSolved += todaySolved;
                          existing.dailyGoal = int.parse(dailyGoalCtrl.text);
                          existing.totalGoal = int.parse(totalGoalCtrl.text);
                          existing.lastUpdated = DateTime.now();

                          // Shift weekly history
                          final history = existing.weeklyHistory;
                          if (history.length >= 7) history.removeAt(0);
                          history.add(todaySolved);
                          existing.weeklyHistory = history;

                          await StorageService.updateCodingProgress(existing);
                        }
                        _load();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
