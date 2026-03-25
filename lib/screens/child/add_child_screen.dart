import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../state/child_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glassmorphic_card.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'female';
  bool _isLoading = false;
  ChildModel? _editingChild;
  bool _isEdit = false;

  // Photo state
  File? _imageFile;
  bool _photoRemoved = false; // track explicit removal when editing

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ChildModel && !_isEdit) {
      _editingChild = args;
      _isEdit = true;
      _nameCtrl.text = args.name;
      _birthDate = args.birthDate;
      _gender = args.gender;
      _notesCtrl.text = args.notes ?? '';
      // Pre-load existing photo
      if (args.photoUrl != null && File(args.photoUrl!).existsSync()) {
        _imageFile = File(args.photoUrl!);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Image helpers ────────────────────────────────────────────────────────

  Future<String> _persistImage(XFile xFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(dir.path, 'child_avatars'));
    if (!avatarsDir.existsSync()) avatarsDir.createSync(recursive: true);
    final ext = p.extension(xFile.path).isNotEmpty ? p.extension(xFile.path) : '.jpg';
    final dest = p.join(avatarsDir.path, '${_uuid.v4()}$ext');
    await File(xFile.path).copy(dest);
    return dest;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() {
        _imageFile = File(picked.path);
        _photoRemoved = false;
      });
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Child\'s Photo',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: _iconTile(Icons.camera_alt_rounded, AppColors.primary),
                title: Text('Take a Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
              ),
              ListTile(
                leading: _iconTile(Icons.photo_library_rounded, AppColors.pink),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: _iconTile(Icons.delete_outline_rounded, Colors.red),
                  title: Text('Remove Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() { _imageFile = null; _photoRemoved = true; });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconTile(IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      );

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a birth date')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Persist photo if a new one was picked (different from existing path)
      String? savedPhotoPath;
      if (_imageFile != null) {
        final existingPath = _editingChild?.photoUrl;
        if (existingPath == null || _imageFile!.path != existingPath) {
          savedPhotoPath = await _persistImage(XFile(_imageFile!.path));
        } else {
          savedPhotoPath = existingPath; // unchanged
        }
      } else if (_photoRemoved) {
        savedPhotoPath = null; // explicitly removed
      } else {
        savedPhotoPath = _editingChild?.photoUrl; // keep existing
      }

      final child = ChildModel(
        id: _editingChild?.id ?? _uuid.v4(),
        name: _nameCtrl.text.trim(),
        birthDate: _birthDate!,
        gender: _gender,
        photoUrl: savedPhotoPath,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );

      final provider = context.read<ChildProvider>();
      if (_isEdit) {
        await provider.updateChild(child);
      } else {
        await provider.addChild(child);
      }

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = _imageFile != null;
    final avatarGradient = _gender == 'female' ? AppColors.primaryGradient : AppColors.purpleTeal;
    final initial = _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Child' : 'Add Child'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Avatar picker ───────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Circle / photo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: hasPhoto
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.file(
                                  _imageFile!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: avatarGradient,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.poppins(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      // Camera badge
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppColors.backgroundDark : Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              // Helper text below avatar
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Text(
                    hasPhoto ? 'Tap to change photo' : 'Tap to add a photo',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),

              // ── Form fields ─────────────────────────────────────────────
              GlassmorphicCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: "Child's Name",
                        prefixIcon: Icon(Icons.child_care_rounded),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter a name';
                        if (v.trim().length < 2) return 'Name must be at least 2 characters';
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    // Birth date
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          helpText: 'Select Birth Date',
                        );
                        if (picked != null) setState(() => _birthDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.dividerLight),
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? AppColors.cardDark : Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_rounded, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              _birthDate != null
                                  ? DateFormat('dd MMMM yyyy').format(_birthDate!)
                                  : 'Select Birth Date',
                              style: TextStyle(
                                color: _birthDate != null
                                    ? Theme.of(context).textTheme.bodyMedium?.color
                                    : AppColors.textSecondaryLight,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondaryLight),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),

                    // Gender
                    Text('Gender', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _GenderOption(value: 'female', label: 'Girl', icon: '👧', selected: _gender, onSelect: (v) => setState(() => _gender = v)),
                        const SizedBox(width: 12),
                        _GenderOption(value: 'male', label: 'Boy', icon: '👦', selected: _gender, onSelect: (v) => setState(() => _gender = v)),
                        const SizedBox(width: 12),
                        _GenderOption(value: 'other', label: 'Other', icon: '🌟', selected: _gender, onSelect: (v) => setState(() => _gender = v)),
                      ],
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.notes_rounded),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              GradientButton(
                text: _isEdit ? 'Save Changes' : 'Add Child',
                isLoading: _isLoading,
                onPressed: _save,
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String value, label, icon, selected;
  final ValueChanged<String> onSelect;

  const _GenderOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
