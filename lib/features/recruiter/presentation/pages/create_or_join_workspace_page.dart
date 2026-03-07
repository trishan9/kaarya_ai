import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/snackbar_utils.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/my_text_form_field_widget.dart';
import 'package:kaarya/features/recruiter/presentation/pages/location_picker_page.dart';
import 'package:kaarya/features/recruiter/presentation/view_model/recruiter_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _industries = [
  'Technology',
  'Healthcare',
  'Finance',
  'Education',
  'Retail',
  'Manufacturing',
  'Consulting',
  'Media & Entertainment',
  'Non-profit',
  'Government',
  'Other',
];

class CreateOrJoinWorkspacePage extends ConsumerStatefulWidget {
  const CreateOrJoinWorkspacePage({super.key});

  @override
  ConsumerState<CreateOrJoinWorkspacePage> createState() =>
      _CreateOrJoinWorkspacePageState();
}

class _CreateOrJoinWorkspacePageState
    extends ConsumerState<CreateOrJoinWorkspacePage> {
  int _selectedTab = 0;

  final _createFormKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _designationController = TextEditingController(text: 'Hiring Manager');

  final _joinFormKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _joinDesignationController = TextEditingController(text: 'Talent Partner');

  String? _selectedIndustry;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _locationController.dispose();
    _designationController.dispose();
    _inviteCodeController.dispose();
    _joinDesignationController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => LocationPickerPage(
          initialAddress: _locationController.text.isEmpty
              ? null
              : _locationController.text,
          onPicked: (address) {
            _locationController.text = address;
            setState(() {});
          },
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _submitCreate() async {
    if (!_createFormKey.currentState!.validate()) return;
    if (_selectedIndustry == null || _selectedIndustry!.isEmpty) {
      SnackbarUtils.showError(context, 'Please select an industry');
      return;
    }
    setState(() => _isSubmitting = true);
    final error = await ref.read(recruiterViewModelProvider.notifier).createWorkspace(
          name: _companyNameController.text.trim(),
          industry: _selectedIndustry!,
          location: _locationController.text.trim(),
          designation: _designationController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error != null) {
      SnackbarUtils.showError(context, error);
    } else {
      SnackbarUtils.showSuccess(context, 'Workspace created successfully');
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _submitJoin() async {
    if (!_joinFormKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final error = await ref.read(recruiterViewModelProvider.notifier).joinWorkspace(
          inviteCode: _inviteCodeController.text.trim(),
          designation: _joinDesignationController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error != null) {
      SnackbarUtils.showError(context, error);
    } else {
      SnackbarUtils.showSuccess(context, 'Joined workspace successfully');
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create or Join Workspace',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create a new company workspace or join an existing one via invite code.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _buildTabBar(),
            const SizedBox(height: 24),
            if (_selectedTab == 0) _buildCreateForm() else _buildJoinForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Row(
        children: [
          _TabChip(
            label: 'Create Workspace',
            icon: LucideIcons.plus,
            selected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _TabChip(
            label: 'Join By Code',
            icon: LucideIcons.link,
            selected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return Form(
      key: _createFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyTextFormField(
            controller: _companyNameController,
            text: 'Company Name',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Company name is required' : null,
          ),
          const SizedBox(height: 16),
          _IndustryDropdown(
            value: _selectedIndustry,
            onChanged: (v) => setState(() => _selectedIndustry = v),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:           MyTextFormField(
            controller: _locationController,
            text: 'Search city, office, or click on map',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Location is required' : null,
          ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(LucideIcons.mapPin, size: 18),
                label: const Text('Pick on map'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Search a place or click the map to set location.',
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          MyTextFormField(
            controller: _designationController,
            text: 'Your Designation',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Designation is required' : null,
          ),
          const SizedBox(height: 28),
          MyButton(
            onPressed: _isSubmitting ? () {} : () => _submitCreate(),
            text: _isSubmitting ? 'Creating...' : 'Create Workspace',
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinForm() {
    return Form(
      key: _joinFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyTextFormField(
            controller: _inviteCodeController,
            text: 'Invite code (e.g. KR-AB12CD34)',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Invite code is required' : null,
          ),
          const SizedBox(height: 16),
          MyTextFormField(
            controller: _joinDesignationController,
            text: 'Designation (e.g. Talent Partner)',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Designation is required' : null,
          ),
          const SizedBox(height: 28),
          MyButton(
            onPressed: _isSubmitting ? () {} : () => _submitJoin(),
            text: _isSubmitting ? 'Joining...' : 'Join Workspace',
            icon: const Icon(LucideIcons.link, size: 18, color: Colors.white),
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textLight,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndustryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _IndustryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Industry',
        hintText: 'Select industry',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderStroke),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _industries
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null || v.isEmpty ? 'Please select an industry' : null,
    );
  }
}
