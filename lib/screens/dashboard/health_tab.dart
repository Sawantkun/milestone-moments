import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../state/child_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/health_record_model.dart';
import '../../models/child_model.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/empty_state.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddMeasurementSheet(BuildContext context, ChildModel child) {
    final heightCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final headCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add Measurement', style: Theme.of(context).textTheme.headlineSmall),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: child.birthDate,
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setModalState(() => selectedDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.dividerLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: heightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height_rounded)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.monitor_weight_outlined)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: headCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Head Circumference (cm)', prefixIcon: Icon(Icons.face_outlined)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(labelText: 'Notes (optional)', prefixIcon: Icon(Icons.notes_rounded)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final record = HealthRecord(
                          id: _uuid.v4(),
                          childId: child.id,
                          date: selectedDate,
                          heightCm: double.tryParse(heightCtrl.text),
                          weightKg: double.tryParse(weightCtrl.text),
                          headCircumferenceCm: double.tryParse(headCtrl.text),
                          notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                        );
                        await context.read<ChildProvider>().addHealthRecord(record);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Save Measurement'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProvider>();
    final selected = childProvider.selectedChild;
    final children = childProvider.children;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Growth'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Height'),
            Tab(text: 'Weight'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.primary,
        ),
        actions: [
          if (children.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButton<String>(
                value: selected?.id,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.expand_more_rounded),
                items: children
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (id) {
                  if (id != null) childProvider.selectChild(id);
                },
              ),
            ),
        ],
      ),
      body: selected == null
          ? const EmptyState(
              icon: Icons.favorite_outline_rounded,
              title: 'No child selected',
              subtitle: 'Add a child to track health',
            )
          : _HealthBody(
              child: selected,
              childProvider: childProvider,
              tabController: _tabController,
            ).animate().fadeIn(delay: 100.ms),
      floatingActionButton: selected == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddMeasurementSheet(context, selected),
              child: const Icon(Icons.add_rounded),
            ).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
    );
  }
}

class _HealthBody extends StatelessWidget {
  final ChildModel child;
  final ChildProvider childProvider;
  final TabController tabController;

  const _HealthBody({
    required this.child,
    required this.childProvider,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final records = childProvider.healthRecordsForChild(child.id);
    final latest = records.isNotEmpty ? records.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        children: [
          // Current stats card
          if (latest != null)
            GlassmorphicCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatItem(
                    label: 'Height',
                    value: latest.heightCm != null ? '${latest.heightCm!.toStringAsFixed(1)} cm' : '—',
                    icon: Icons.height_rounded,
                    color: AppColors.primary,
                  ),
                  _Divider(),
                  _StatItem(
                    label: 'Weight',
                    value: latest.weightKg != null ? '${latest.weightKg!.toStringAsFixed(1)} kg' : '—',
                    icon: Icons.monitor_weight_outlined,
                    color: AppColors.pink,
                  ),
                  _Divider(),
                  _StatItem(
                    label: 'Head',
                    value: latest.headCircumferenceCm != null ? '${latest.headCircumferenceCm!.toStringAsFixed(1)} cm' : '—',
                    icon: Icons.face_outlined,
                    color: AppColors.teal,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // Chart
          GlassmorphicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 220,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      _GrowthChart(
                        records: records,
                        type: 'height',
                        color: AppColors.primary,
                        label: 'Height (cm)',
                      ),
                      _GrowthChart(
                        records: records,
                        type: 'weight',
                        color: AppColors.pink,
                        label: 'Weight (kg)',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Records list
          Text('Measurement History', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (records.isEmpty)
            const EmptyState(
              icon: Icons.monitor_heart_outlined,
              title: 'No measurements yet',
              subtitle: 'Tap + to add the first measurement',
            )
          else
            ...records.take(10).map((r) => _RecordTile(record: r)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: AppColors.dividerLight);
  }
}

class _GrowthChart extends StatelessWidget {
  final List<HealthRecord> records;
  final String type;
  final Color color;
  final String label;

  const _GrowthChart({
    required this.records,
    required this.type,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<HealthRecord>.from(records)..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final r = sorted[i];
      final value = type == 'height' ? r.heightCm : r.weightKg;
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    if (spots.isEmpty) {
      return Center(
        child: Text('No data yet', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.withOpacity(0.15),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('MMM').format(sorted[idx].date),
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondaryLight),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondaryLight),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                radius: 4,
                color: color,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final HealthRecord record;

  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.favorite_outline_rounded, color: AppColors.primary, size: 22),
        ),
        title: Text(
          DateFormat('dd MMM yyyy').format(record.date),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          [
            if (record.heightCm != null) '${record.heightCm!.toStringAsFixed(1)} cm',
            if (record.weightKg != null) '${record.weightKg!.toStringAsFixed(1)} kg',
            if (record.headCircumferenceCm != null) 'HC: ${record.headCircumferenceCm!.toStringAsFixed(1)} cm',
          ].join('  •  '),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: record.notes != null
            ? const Icon(Icons.notes_rounded, size: 18, color: AppColors.textSecondaryLight)
            : null,
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
