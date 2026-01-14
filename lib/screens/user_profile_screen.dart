import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../config/theme_config.dart';
import '../services/auth_service.dart';
import '../services/user_profile_api_service.dart';
import '../models/user_profile.dart';
import '../widgets/profile_image_picker.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await UserProfileApiService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Wylogowanie'),
            content: const Text('Czy na pewno chcesz się wylogować?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Wyloguj'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      try {
        await UserProfileApiService.logoutUser();
        await AuthService.logout();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        await AuthService.logout();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProfile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nie udało się załadować profilu',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUserProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(theme),
            const SizedBox(height: 32),
            _buildSettingsSection(theme),
            const SizedBox(height: 32),
            _buildAccountActionsSection(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final profile = _userProfile!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileImagePicker(
            key: ValueKey(profile.profileImageUrl ?? 'no-image'),
            currentImageUrl: profile.profileImageUrl,
            onImageUpdated: (newImageUrl) async {
              await _loadUserProfile();
            },
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleDisplayName(profile.role),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'Uczeń';
      case 'teacher':
        return 'Nauczyciel';
      case 'admin':
        return 'Administrator';
      default:
        return 'Użytkownik';
    }
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ustawienia',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        themeProvider.themeModeIcon,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: const Text('Motyw aplikacji'),
                    subtitle: Text(themeProvider.themeModeDisplayName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeSelector(context, themeProvider),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.green),
                ),
                title: const Text('Odśwież profil'),
                subtitle: const Text('Pobierz najnowsze dane'),
                trailing:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.chevron_right),
                onTap:
                    _isLoading
                        ? null
                        : () async {
                          await _loadUserProfile();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil został odświeżony'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konto',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit, color: Colors.orange),
                ),
                title: const Text('Edytuj profil'),
                subtitle: const Text('Zmień swoje dane osobowe'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  if (_userProfile != null) {
                    final updatedProfile = await Navigator.of(
                      context,
                    ).push<UserProfile>(
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                EditProfileScreen(userProfile: _userProfile!),
                      ),
                    );
                    if (updatedProfile != null) {
                      setState(() {
                        _userProfile = updatedProfile;
                      });
                    }
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.logout, color: theme.colorScheme.error),
                ),
                title: Text(
                  'Wyloguj się',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Zakończ sesję'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wybierz motyw',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ...AppThemeMode.values.map((mode) {
                  final isSelected = themeProvider.themeMode == mode;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            isSelected
                                ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                                : null,
                      ),
                      child: Icon(
                        _getThemeModeIcon(mode),
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(_getThemeModeDisplayName(mode)),
                    subtitle: Text(_getThemeModeDescription(mode)),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : null,
                    onTap: () {
                      themeProvider.setThemeMode(mode);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.brightness_7;
      case AppThemeMode.dark:
        return Icons.brightness_2;
    }
  }

  String _getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Systemowy';
      case AppThemeMode.light:
        return 'Jasny';
      case AppThemeMode.dark:
        return 'Ciemny';
    }
  }

  String _getThemeModeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Automatycznie dostosowuje się do ustawień systemu';
      case AppThemeMode.light:
        return 'Jasny motyw zawsze aktywny';
      case AppThemeMode.dark:
        return 'Ciemny motyw zawsze aktywny';
    }
  }
}
