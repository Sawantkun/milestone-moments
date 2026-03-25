import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/child_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/reminder_model.dart';
import '../../models/child_model.dart';
import '../../widgets/reminder_card.dart';
import '../../widgets/empty_state.dart';

class RemindersTab extends StatelessWidget {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProvider>();
    final reminders = childProvider.reminders.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    final monthEnd = now.add(const Duration(days: 30));

    final thisWeek = reminders.where((r) => !r.isCompleted && r.dateTime.isAfter(now) && r.dateTime.isBefore(weekEnd)).toList();
    final nextMonth = reminders.where((r) => !r.isCompleted && r.dateTime.isAfter(weekEnd) && r.dateTime.isBefore(monthEnd)).toList();
    final later = reminders.where((r) => !r.isCompleted && r.dateTime.isAfter(monthEnd)).toList();
    final completed = reminders.where((r) => r.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: reminders.isEmpty
          ? EmptyState(
              icon: Icons.notifications_outlined,
              title: 'No reminders yet',
              subtitle: 'Tap + to add your first reminder',
              actionLabel: 'Add Reminder',
              onAction: () => _showAddReminderSheet(context, childProvider),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                if (thisWeek.isNotEmpty) ...[
                  _SectionLabel(label: 'This Week').animate().fadeIn(delay: 100.ms),
                  ...thisWeek.asMap().entries.map((e) => _buildReminderCard(context, e.value, childProvider, e.key * 60)),
                ],
                if (nextMonth.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionLabel(label: 'Next Month').animate().fadeIn(delay: 150.ms),
                  ...nextMonth.asMap().entries.map((e) => _buildReminderCard(context, e.value, childProvider, (thisWeek.length + e.key) * 60)),
                ],
                if (later.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionLabel(label: 'Later').animate().fadeIn(delay: 200.ms),
                  ...later.asMap().entries.map((e) => _buildReminderCard(context, e.value, childProvider, (thisWeek.length + nextMonth.length + e.key) * 60)),
                ],
                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionLabel(label: 'Completed', muted: true).animate().fadeIn(delay: 250.ms),
                  ...completed.asMap().entries.map((e) => _buildReminderCard(context, e.value, childProvider, 0)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderSheet(context, childProvider),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildReminderCard(BuildContext context, ReminderModel reminder, ChildProvider childProvider, int delayMs) {
    final child = childProvider.children.firstWhere(
      (c) => c.id == reminder.childId,
      orElse: () => ChildModel(id: '', name: 'Unknown', birthDate: DateTime.now(), gender: 'other'),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ReminderCard(
        reminder: reminder,
        childName: child.name,
        onToggle: () => childProvider.toggleReminderComplete(reminder.id),
        onDelete: () => childProvider.deleteReminder(reminder.id),
      ).animate().fadeIn(delay: Duration(milliseconds: delayMs)).slideX(begin: 0.1, end: 0),
    );
  }

  void _showAddReminderSheet(BuildContext context, ChildProvider childProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddReminderSheet(childProvider: childProvider),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool muted;

  const _SectionLabel({required this.label, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: muted ? AppColors.textSecondaryLight : AppColors.primary,
        ),
      ),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  final ChildProvider childProvider;

  const _AddReminderSheet({required this.childProvider});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  static const _uuid = Uuid();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  ReminderType _type = ReminderType.vaccination;
  String? _selectedChildId;

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.childProvider.selectedChild?.id ?? widget.childProvider.children.firstOrNull?.id;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.childProvider.children;

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Reminder', style: Theme.of(context).textTheme.headlineSmall),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 16),

          // Child selector
          if (children.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: _selectedChildId,
              decoration: const InputDecoration(labelText: 'Child', prefixIcon: Icon(Icons.child_care_rounded)),
              items: children.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedChildId = v),
            ),
            const SizedBox(height: 12),
          ],

          // Title
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title_rounded)),
          ),
          const SizedBox(height: 12),

          // Description
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined)),
          ),
          const SizedBox(height: 12),

          // Type
          DropdownButtonFormField<ReminderType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category_outlined)),
            items: ReminderType.values.map((t) => DropdownMenuItem(
              value: t,
              child: Text('${t.emoji} ${t.displayName}'),
            )).toList(),
            onChanged: (v) { if (v != null) setState(() => _type = v); },
          ),
          const SizedBox(height: 12),

          // Date
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (d != null) setState(() => _selectedDate = d);
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
                  Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_titleCtrl.text.trim().isEmpty || _selectedChildId == null) return;
                final reminder = ReminderModel(
                  id: _uuid.v4(),
                  childId: _selectedChildId!,
                  title: _titleCtrl.text.trim(),
                  description: _descCtrl.text.trim(),
                  dateTime: _selectedDate,
                  type: _type,
                );
                await widget.childProvider.addReminder(reminder);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save Reminder'),
            ),
          ),
        ],
      ),
    );
  }
}
