import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:praca_inzynierska_front/models/user_profile.dart';
import 'package:praca_inzynierska_front/services/user_profile_api_service.dart';
import 'package:praca_inzynierska_front/services/api_client_service.dart';
import 'package:praca_inzynierska_front/screens/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profile = await UserProfileApiService.getUserProfile();
      
      setState(() {
        _userProfile = profile;
        _isLoading = false;
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      print('Profile loading error: $e');

      // Jeśli sesja wygasła, przekieruj na ekran logowania
      if (e.toString().contains('Sesja wygasła')) {
        _navigateToLogin();
      } else if (e.toString().contains('500') || e.toString().contains('AttributeError')) {
        // Serwer ma problem z implementacją - pokaż komunikat
        setState(() {
          _error = 'Backend wymaga poprawki modelu Teacher. \nSprawdź logi serwera - problem z Teacher.first_name/last_name vs Teacher.name';
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_userProfile == null) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      _showError('Wszystkie pola są wymagane');
      return;
    }

    // Sprawdź czy coś się zmieniło
    if (firstName == _userProfile!.firstName && lastName == _userProfile!.lastName) {
      _showSuccess('Profil jest aktualny');
      return;
    }

    try {
      setState(() => _isUpdating = true);

      final updateRequest = ProfileUpdateRequest(
        firstName: firstName,
        lastName: lastName,
      );

      final updatedProfile = await UserProfileApiService.updateUserProfile(updateRequest);
      
      setState(() {
        _userProfile = updatedProfile;
        _isUpdating = false;
      });

      _showSuccess('Profil został zaktualizowany');
    } catch (e) {
      setState(() => _isUpdating = false);
      _showError(e.toString());

      if (e.toString().contains('Sesja wygasła')) {
        _navigateToLogin();
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wybierz źródło zdjęcia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Aparat'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage([ImageSource? source]) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Jeśli nie podano źródła, pokaż dialog wyboru
      if (source == null) {
        _showImageSourceDialog();
        return;
      }

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (image == null) {
        print('Image picker cancelled by user');
        return;
      }

      // Sprawdź czy plik istnieje
      final file = File(image.path);
      if (!await file.exists()) {
        throw Exception('Wybrany plik nie istnieje');
      }

      // Sprawdź rozmiar pliku
      final fileSize = await file.length();
      print('Selected file size: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
      
      if (fileSize > 5 * 1024 * 1024) { // 5MB
        throw Exception('Plik jest za duży. Maksymalny rozmiar to 5MB.');
      }

      // Sprawdź typ pliku na podstawie rozszerzenia
      final extension = image.path.toLowerCase();
      if (!extension.endsWith('.jpg') && 
          !extension.endsWith('.jpeg') && 
          !extension.endsWith('.png') && 
          !extension.endsWith('.webp')) {
        throw Exception('Nieobsługiwany format pliku. Użyj JPG, PNG lub WebP.');
      }

      setState(() => _isUpdating = true);

      await UserProfileApiService.uploadProfileImage(file);
      
      // Przeładuj profil po zmianie zdjęcia
      await _loadUserProfile();

      _showSuccess('Zdjęcie profilowe zostało zaktualizowane');
    } catch (e) {
      setState(() => _isUpdating = false);
      print('Error in _pickAndUploadImage: $e');
      
      String errorMessage = e.toString();
      if (errorMessage.contains('camera_access_denied')) {
        errorMessage = 'Brak dostępu do aparatu. Sprawdź uprawnienia w ustawieniach.';
      } else if (errorMessage.contains('photo_access_denied')) {
        errorMessage = 'Brak dostępu do galerii. Sprawdź uprawnienia w ustawieniach.';
      } else if (errorMessage.contains('Sesja wygasła')) {
        _navigateToLogin();
        return;
      }
      
      _showError(errorMessage);
    }
  }

  Future<void> _deleteProfileImage() async {
    if (_userProfile?.profileImageUrl == null) {
      _showError('Brak zdjęcia profilowego do usunięcia');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń zdjęcie profilowe'),
        content: const Text('Czy na pewno chcesz usunąć zdjęcie profilowe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isUpdating = true);

      await UserProfileApiService.deleteProfileImage();
      
      // Przeładuj profil po usunięciu zdjęcia
      await _loadUserProfile();

      _showSuccess('Zdjęcie profilowe zostało usunięte');
    } catch (e) {
      setState(() => _isUpdating = false);
      _showError(e.toString());

      if (e.toString().contains('Sesja wygasła')) {
        _navigateToLogin();
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wyloguj'),
        content: const Text('Czy na pewno chcesz się wylogować?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Wyloguj'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await UserProfileApiService.logoutUser();
      _navigateToLogin();
    } catch (e) {
      // Nawet w przypadku błędu przekieruj na ekran logowania
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  String? _getCompleteImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return null;
    // Jeśli URL już jest kompletny (zaczyna się od http), zwróć go bez zmian
    if (relativeUrl.startsWith('http')) return relativeUrl;
    // W przeciwnym razie dodaj base URL
    return '${ApiClient.baseUrl}$relativeUrl';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mój Profil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Wyloguj',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Błąd podczas ładowania profilu',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_userProfile == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileForm(),
          const SizedBox(height: 24),
          _buildStatsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _getCompleteImageUrl(_userProfile!.profileImageUrl) != null
                      ? NetworkImage(_getCompleteImageUrl(_userProfile!.profileImageUrl)!)
                      : null,
                  child: _getCompleteImageUrl(_userProfile!.profileImageUrl) == null
                      ? Text(
                          _userProfile!.firstName.isNotEmpty
                              ? _userProfile!.firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'upload') {
                        _pickAndUploadImage();
                      } else if (value == 'delete') {
                        _deleteProfileImage();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'upload',
                        child: Row(
                          children: [
                            Icon(Icons.add_a_photo, size: 18),
                            SizedBox(width: 8),
                            Text('Dodaj zdjęcie'),
                          ],
                        ),
                      ),
                      if (_userProfile!.profileImageUrl != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Usuń zdjęcie', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userProfile!.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userProfile!.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _userProfile!.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dane osobowe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Imię',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nazwisko',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Zaktualizuj profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _userProfile!.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Twoje statystyki',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildGeneralStats(stats),
        const SizedBox(height: 16),
        if (stats.favoriteTeacher != null) _buildFavoriteTeacherCard(stats),
        const SizedBox(height: 16),
        if (stats.favoriteSubject != null) _buildFavoriteSubjectCard(stats),
      ],
    );
  }

  Widget _buildGeneralStats(UserProfileStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Próby quizów',
            stats.totalQuizAttempts.toString(),
            Icons.quiz,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Ukończone',
            stats.totalCompletedQuizzes.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Średnia',
            stats.overallAvgScore != null
                ? '${stats.overallAvgScore!.toStringAsFixed(1)}%'
                : 'N/A',
            Icons.trending_up,
            _getScoreColor(stats.overallAvgScore ?? 0),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteTeacherCard(UserProfileStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.orange[800],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ulubiony nauczyciel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stats.favoriteTeacher!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stats.favoriteTeacherConversations} konwersacji',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteSubjectCard(UserProfileStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school,
                color: Colors.purple[800],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ulubiony przedmiot',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stats.favoriteSubject!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Średnia: ${stats.favoriteSubjectAvgScore!.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getScoreColor(stats.favoriteSubjectAvgScore!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(stats.favoriteSubjectAvgScore!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${stats.favoriteSubjectAvgScore!.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
