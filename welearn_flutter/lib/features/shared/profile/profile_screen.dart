import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../auth/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _editing = false;
  bool _loading = false;
  String? _error;
  File? _newPhoto;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl.text = user?.name ?? '';
    _phoneCtrl.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_editing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _editing = true))
          else
            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _editing = false; _error = null; })),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: colors.primary.withOpacity(0.15),
                    child: _newPhoto != null
                        ? ClipOval(child: Image.file(_newPhoto!, width: 104, height: 104, fit: BoxFit.cover))
                        : user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.profilePhoto!,
                                  width: 104,
                                  height: 104,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const CircularProgressIndicator(),
                                  errorWidget: (_, __, ___) => Text(user.name?[0].toUpperCase() ?? 'U', style: TextStyle(fontSize: 36, color: colors.primary, fontWeight: FontWeight.bold)),
                                ),
                              )
                            : Text(
                                (user?.name?[0] ?? 'U').toUpperCase(),
                                style: TextStyle(fontSize: 36, color: colors.primary, fontWeight: FontWeight.bold),
                              ),
                  ),
                  if (_editing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(user?.name ?? '', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(user?.email ?? '', style: TextStyle(color: colors.onSurfaceVariant)),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (user?.role ?? '').toUpperCase(),
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: colors.errorContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: TextStyle(color: colors.onErrorContainer)),
                ),
              TextFormField(
                controller: _nameCtrl,
                enabled: _editing,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                enabled: _editing,
                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.email ?? '',
                enabled: false,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.role ?? '',
                enabled: false,
                decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge_outlined)),
              ),
              if (_editing) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _saveProfile,
                    child: _loading
                        ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes'),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.orange),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordSheet(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: colors.surfaceVariant.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmSignOut(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.red.withOpacity(0.05),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _newPhoto = File(picked.path));
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(apiClientProvider);
      if (_newPhoto != null) {
        await client.uploadFile(
          ApiEndpoints.profile,
          filePath: _newPhoto!.path,
          fieldName: 'profilePhoto',
          data: {'name': _nameCtrl.text.trim(), 'phone': _phoneCtrl.text.trim()},
        );
      } else {
        await client.patch(ApiEndpoints.profile, data: {
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
        });
      }
      await ref.read(authStateProvider.notifier).updateProfile({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      setState(() { _editing = false; _newPhoto = null; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    }
    setState(() => _loading = false);
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                ),
              TextFormField(controller: _currentCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password'), validator: (v) => v == null || v.length < 8 ? 'Min 8 chars' : null),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                validator: (v) => v != _newCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.changePassword, data: {
        'currentPassword': _currentCtrl.text,
        'newPassword': _newCtrl.text,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}
