import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../domain/profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _schoolController;
  late TextEditingController _bioController;
  String _selectedGrade = '';
  List<String> _selectedSubjects = [];

  final List<String> _grades = [
    "Middle School",
    "High School (9th)",
    "High School (10th)",
    "High School (11th)",
    "High School (12th)",
    "Undergrad",
    "Graduate"
  ];

  final List<String> _subjects = [
    "Math", "Biology", "History", "Physics", "Chemistry", "Literature", "CS", "Economics", "Psychology", "Art"
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _schoolController = TextEditingController(text: profile.school);
    _bioController = TextEditingController(text: profile.bio);
    _selectedGrade = profile.grade;
    _selectedSubjects = List.from(profile.subjects);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _schoolController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedProfile = ProfileData(
      name: _nameController.text.trim().isEmpty ? 'Lekture User' : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? 'student@example.com' : _emailController.text.trim(),
      bio: _bioController.text.trim(),
      school: _schoolController.text.trim(),
      grade: _selectedGrade,
      subjects: _selectedSubjects,
    );

    ref.read(profileProvider.notifier).updateProfile(updatedProfile);
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  void _toggleSubject(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
      } else {
        _selectedSubjects.add(subject);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final notes = ref.watch(notesProvider);
    final storage = ref.watch(localStorageServiceProvider);
    
    final streak = storage.getStreakDays();
    final joined = storage.getJoinedDate();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.displaySmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isEditing
                          ? (_nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'L')
                          : (profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'L'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isEditing) ...[
                    Text(
                      profile.name,
                      style: theme.textTheme.displaySmall?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isEditing) ...[
              // Display name Field
              _buildTextField('Display name', _nameController, 'e.g. Lekture User'),
              const SizedBox(height: 14),
              
              // Email Field
              _buildTextField('Email', _emailController, 'student@example.com'),
              const SizedBox(height: 14),

              // School Field
              _buildTextField('School', _schoolController, 'e.g. Lincoln High School'),
              const SizedBox(height: 14),

              // Grade Level Selector
              _buildSectionTitle('Grade level'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _grades.map((g) {
                  final isSelected = _selectedGrade == g;
                  return ChoiceChip(
                    label: Text(g, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.surface : Colors.grey[200],
                    onSelected: (selected) {
                      setState(() {
                        _selectedGrade = selected ? g : '';
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Bio Field
              _buildTextField('Bio', _bioController, 'Tell us about your study goals...', maxLines: 3),
              const SizedBox(height: 14),

              // Favorite Subjects Selector
              _buildSectionTitle('Favorite subjects'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _subjects.map((s) {
                  final isSelected = _selectedSubjects.contains(s);
                  return FilterChip(
                    label: Text(s, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.surface : Colors.grey[200],
                    checkmarkColor: Colors.white,
                    onSelected: (selected) => _toggleSubject(s),
                  );
                }).toList(),
              ),
            ] else ...[
              // Read mode rows
              _buildReadRow('School', profile.school.isEmpty ? '—' : profile.school, isDark),
              const SizedBox(height: 10),
              _buildReadRow('Grade', profile.grade.isEmpty ? '—' : profile.grade, isDark),
              const SizedBox(height: 10),
              _buildReadRow('Bio', profile.bio.isEmpty ? '—' : profile.bio, isDark, multiline: true),
              const SizedBox(height: 14),

              // Subjects Chips View
              if (profile.subjects.isNotEmpty) ...[
                _buildSectionTitle('Subjects'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.subjects.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Stat boxes
              Row(
                children: [
                  Expanded(child: _buildStatBox('Notes', '${notes.length}', isDark)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatBox('Streak', '$streak days', isDark)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatBox('Joined', joined, isDark)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String placeholder, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildReadRow(String label, String value, bool isDark, {bool multiline = false}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(label),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              height: multiline ? 1.4 : 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
