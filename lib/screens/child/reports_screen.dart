import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/child_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../services/pdf_service.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/empty_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final PdfService _pdfService = PdfService();
  bool _isGenerating = false;
  String? _selectedChildId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final childProvider = context.read<ChildProvider>();
    _selectedChildId ??= childProvider.selectedChild?.id;
  }

  Future<void> _generateAndShare() async {
    final childProvider = context.read<ChildProvider>();
    if (_selectedChildId == null) return;

    final child = childProvider.children.firstWhere(
      (c) => c.id == _selectedChildId,
      orElse: () => childProvider.children.first,
    );

    setState(() => _isGenerating = true);
    try {
      final milestones = childProvider.milestonesForChild(child.id);
      final healthRecords = childProvider.healthRecordsForChild(child.id);
      final reminders = childProvider.remindersForChild(child.id);

      final pdfBytes = await _pdfService.generateChildReport(
        child: child,
        milestones: milestones,
        healthRecords: healthRecords,
        reminders: reminders,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${child.name.replaceAll(' ', '_')}_MilestoneMoments_Report.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProvider>();
    final children = childProvider.children;

    if (children.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body: const EmptyState(
          icon: Icons.picture_as_pdf_rounded,
          title: 'No children added',
          subtitle: 'Add a child first to generate a report',
        ),
      );
    }

    final selectedChild = _selectedChildId != null
        ? children.firstWhere((c) => c.id == _selectedChildId, orElse: () => children.first)
        : children.first;

    final milestones = childProvider.milestonesForChild(selectedChild.id);
    final healthRecords = childProvider.healthRecordsForChild(selectedChild.id);
    final reminders = childProvider.remindersForChild(selectedChild.id);

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.purpleTeal,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Generate PDF Report',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Export a comprehensive summary of your child\'s development progress',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.85)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Child selector
            if (children.length > 1) ...[
              Text('Select Child', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GlassmorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButton<String>(
                  value: _selectedChildId,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: children.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Text(c.name),
                        const SizedBox(width: 8),
                        Text('(${c.ageString})', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedChildId = v),
                ),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 20),
            ],

            // Stats summary
            Text('Report Summary', style: Theme.of(context).textTheme.titleMedium).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  icon: Icons.star_rounded,
                  label: 'Milestones',
                  value: milestones.length.toString(),
                  color: AppColors.primary,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.favorite_rounded,
                  label: 'Health Records',
                  value: healthRecords.length.toString(),
                  color: AppColors.pink,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.notifications_rounded,
                  label: 'Reminders',
                  value: reminders.length.toString(),
                  color: AppColors.teal,
                ).animate().fadeIn(delay: 350.ms),
              ],
            ),

            const SizedBox(height: 24),

            // What's included
            GlassmorphicCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What\'s included in the report', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  _IncludedItem(icon: Icons.person_outline_rounded, text: 'Child profile and overview'),
                  _IncludedItem(icon: Icons.star_outline_rounded, text: 'Complete milestone journey'),
                  _IncludedItem(icon: Icons.show_chart_rounded, text: 'Growth and health measurements'),
                  _IncludedItem(icon: Icons.notifications_outlined, text: 'Upcoming reminders'),
                  _IncludedItem(icon: Icons.calendar_today_outlined, text: 'Report generation date'),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            GradientButton(
              text: _isGenerating ? 'Generating...' : 'Generate & Share PDF',
              isLoading: _isGenerating,
              onPressed: _generateAndShare,
              gradient: AppColors.purpleTeal,
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'The PDF will be shareable via your device\'s share sheet',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: color),
            ),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _IncludedItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IncludedItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
