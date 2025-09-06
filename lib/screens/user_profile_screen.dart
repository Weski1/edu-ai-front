import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../config/theme_config.dart'; // Dodajemy import dla AppThemeMode
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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
        // Wyloguj na backendzie
        await UserProfileApiService.logoutUser();
        
        // Wyloguj lokalnie
        await AuthService.logout();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        // Nawet jeśli wystąpi błąd z backendem, wylogowujemy lokalnie
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
      return const Center(
        child: CircularProgressIndicator(),
      );
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
            // Profile header
            _buildProfileHeader(theme),
            const SizedBox(height: 32),
            
            // Stats cards
            _buildStatsSection(theme),
            const SizedBox(height: 32),
            
            // Settings section
            _buildSettingsSection(theme),
            const SizedBox(height: 32),
            
            // Account actions
            _buildAccountActionsSection(theme),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final profile = _userProfile!;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar z możliwością edycji
          ProfileImagePicker(
            key: ValueKey(profile.profileImageUrl ?? 'no-image'),
            currentImageUrl: profile.profileImageUrl,
            onImageUpdated: (newImageUrl) async {
              // Odśwież dane profilu z serwera po zmianie zdjęcia
              await _loadUserProfile();
            },
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            profile.fullName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            profile.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          
          // Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleDisplayName(profile.role),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
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

  Widget _buildStatsSection(ThemeData theme) {
    final profile = _userProfile!;
    final stats = profile.stats;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Twoje statystyki',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Ukończone quizy',
                '${stats.totalCompletedQuizzes}',
                Icons.quiz_outlined,
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Średni wynik',
                stats.overallAvgScore != null 
                  ? '${stats.overallAvgScore!.toStringAsFixed(1)}%'
                  : 'Brak danych',
                Icons.trending_up,
                stats.overallAvgScore != null 
                  ? _getScoreColor(stats.overallAvgScore!)
                  : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Łączne próby',
                '${stats.totalQuizAttempts}',
                Icons.psychology,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                stats.favoriteTeacher != null ? 'Ulubiony nauczyciel' : 'Ulubiony przedmiot',
                stats.favoriteTeacher ?? stats.favoriteSubject ?? 'Brak danych',
                stats.favoriteTeacher != null ? Icons.person : Icons.book,
                Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.green,
                  ),
                ),
                title: const Text('Powiadomienia'),
                subtitle: const Text('Zarządzaj powiadomieniami'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to notifications settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funkcja w przygotowaniu')),
                  );
                },
              ),
              
              const Divider(height: 1),
              
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.blue,
                  ),
                ),
                title: const Text('Język'),
                subtitle: const Text('Polski'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to language settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funkcja w przygotowaniu')),
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
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.green,
                  ),
                ),
                title: const Text('Odśwież profil'),
                subtitle: const Text('Pobierz najnowsze dane'),
                trailing: _isLoading 
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
                onTap: _isLoading ? null : () async {
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
                  child: const Icon(
                    Icons.edit,
                    color: Colors.orange,
                  ),
                ),
                title: const Text('Edytuj profil'),
                subtitle: const Text('Zmień swoje dane osobowe'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  if (_userProfile != null) {
                    final updatedProfile = await Navigator.of(context).push<UserProfile>(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(userProfile: _userProfile!),
                      ),
                    );
                    // Jeśli profil został zaktualizowany, odśwież dane
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
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.help,
                    color: Colors.purple,
                  ),
                ),
                title: const Text('Pomoc'),
                subtitle: const Text('FAQ i wsparcie techniczne'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to help
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funkcja w przygotowaniu')),
                  );
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
                  child: Icon(
                    Icons.logout,
                    color: theme.colorScheme.error,
                  ),
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
      builder: (context) => Container(
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
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected 
                      ? Border.all(color: Theme.of(context).colorScheme.primary)
                      : null,
                  ),
                  child: Icon(
                    _getThemeModeIcon(mode),
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(_getThemeModeDisplayName(mode)),
                subtitle: Text(_getThemeModeDescription(mode)),
                trailing: isSelected 
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

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
