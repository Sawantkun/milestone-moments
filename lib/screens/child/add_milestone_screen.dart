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
import '../../models/milestone_model.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glassmorphic_card.dart';

class AddMilestoneScreen extends StatefulWidget {
  const AddMilestoneScreen({super.key});

  @override
  State<AddMilestoneScreen> createState() => _AddMilestoneScreenState();
}

class _AddMilestoneScreenState extends State<AddMilestoneScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  MilestoneCategory _category = MilestoneCategory.other;
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  File? _imageFile;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// Copies the picked image to the app's documents directory so it persists.
  Future<String> _persistImage(XFile picked) async {
    final dir = await getApplicationDocumentsDirectory();
    final milestoneImagesDir = Directory(p.join(dir.path, 'milestone_images'));
    if (!milestoneImagesDir.existsSync()) {
      milestoneImagesDir.createSync(recursive: true);
    }
    final ext = p.extension(picked.path).isNotEmpty ? p.extension(picked.path) : '.jpg';
    final dest = p.join(milestoneImagesDir.path, '${_uuid.v4()}$ext');
    await File(picked.path).copy(dest);
    return dest;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _imageFile = File(picked.path));
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
                'Add Photo',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: Text('Take a Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                subtitle: Text('Open camera', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondaryLight)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.pink),
                ),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                subtitle: Text('Pick an existing photo', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondaryLight)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: Text('Remove Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _imageFile = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final childProvider = context.read<ChildProvider>();
    final child = childProvider.selectedChild;
    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child first')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Persist the image to documents directory if one was picked
      String? savedImagePath;
      if (_imageFile != null) {
        final picker = ImagePicker();
        final xFile = XFile(_imageFile!.path);
        savedImagePath = await _persistImage(xFile);
      }

      final milestone = MilestoneModel(
        id: _uuid.v4(),
        childId: child.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _date,
        category: _category,
        photoUrl: savedImagePath,
      );
      await childProvider.addMilestone(milestone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Milestone "${_titleCtrl.text}" saved!'),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProvider>();
    final child = childProvider.selectedChild;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Milestone${child != null ? ' for ${child.name}' : ''}'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon preview
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _categoryColor(_category).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _categoryColor(_category).withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(_category.emoji, style: const TextStyle(fontSize: 36)),
                  ),
                ),
              ).animate().scale(duration: 300.ms),

              const SizedBox(height: 24),

              GlassmorphicCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Milestone Title',
                        prefixIcon: Icon(Icons.star_outline_rounded),
                        hintText: 'e.g. First steps, Said "mama"...',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter a title';
                        return null;
                      },
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.description_outlined),
                        ),
                        alignLabelWithHint: true,
                        hintText: 'Describe this precious moment...',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please add a description';
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    // Date picker
                    GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: child != null ? child.birthDate : DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _date = d);
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
                            const Icon(Icons.event_rounded, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd MMMM yyyy').format(_date),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondaryLight),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 16),

                    // Category selector
                    Text('Category', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MilestoneCategory.values.map((cat) {
                        final isSelected = _category == cat;
                        final color = _categoryColor(cat);
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? color : color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  cat.displayName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // ── Photo Section ──────────────────────────────────────────
              GlassmorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Photo',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(optional)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_imageFile == null)
                      // Empty state — tap to pick
                      GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primary.withOpacity(0.07)
                                : AppColors.primary.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.25),
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Add a photo',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Camera or gallery',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms)
                    else
                      // Image preview
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Change / remove overlay buttons
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                _overlayButton(
                                  icon: Icons.edit_rounded,
                                  onTap: _showImageSourceSheet,
                                ),
                                const SizedBox(width: 8),
                                _overlayButton(
                                  icon: Icons.close_rounded,
                                  color: Colors.red,
                                  onTap: () => setState(() => _imageFile = null),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95)),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              GradientButton(
                text: 'Save Milestone',
                isLoading: _isLoading,
                onPressed: _save,
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overlayButton({
    required IconData icon,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Color _categoryColor(MilestoneCategory cat) {
    switch (cat) {
      case MilestoneCategory.motor:
        return AppColors.motorColor;
      case MilestoneCategory.language:
        return AppColors.languageColor;
      case MilestoneCategory.social:
        return AppColors.socialColor;
      case MilestoneCategory.cognitive:
        return AppColors.cognitiveColor;
      case MilestoneCategory.other:
        return AppColors.otherColor;
    }
  }
}
