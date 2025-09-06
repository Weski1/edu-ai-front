import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_profile_api_service.dart';
import '../services/api_client_service.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? currentImageUrl;
  final Function(String newImageUrl) onImageUpdated;

  const ProfileImagePicker({
    super.key, 
    required this.currentImageUrl,
    required this.onImageUpdated,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _cacheKey;

  @override
  void initState() {
    super.initState();
    _cacheKey = DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _buildFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    // Jeśli już ma pełny URL, zwróć go
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Dodaj bazowy URL serwera
    return '${ApiClient.baseUrl}$imageUrl';
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            Text(
              'Zmień zdjęcie profilowe',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            // Aparat
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Zrób zdjęcie'),
              subtitle: const Text('Użyj aparatu telefonu'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            
            // Galeria
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: const Text('Wybierz z galerii'),
              subtitle: const Text('Wybierz istniejące zdjęcie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            
            // Usuń zdjęcie (jeśli istnieje)
            if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty)
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Usuń zdjęcie'),
                subtitle: const Text('Usuń obecne zdjęcie profilowe'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteImage();
                },
              ),
            
            const SizedBox(height: 10),
            
            // Anuluj
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isUploading = true);
        
        // Upload zdjęcia
        final imageUrl = await UserProfileApiService.uploadProfileImage(File(image.path));
        
        print('=== PROFILE IMAGE PICKER DEBUG ===');
        print('Returned image URL: $imageUrl');
        print('Current widget URL: ${widget.currentImageUrl}');
        
        // Zaktualizuj cache key dla nowego zdjęcia
        setState(() {
          _cacheKey = DateTime.now().millisecondsSinceEpoch.toString();
        });
        
        // Powiadom o zmianie
        widget.onImageUpdated(imageUrl);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Zdjęcie profilowe zostało zaktualizowane'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas zmiany zdjęcia: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteImage() async {
    try {
      setState(() => _isUploading = true);
      
      await UserProfileApiService.deleteProfileImage();
      
      // Zaktualizuj cache key dla usunięcia zdjęcia
      setState(() {
        _cacheKey = DateTime.now().millisecondsSinceEpoch.toString();
      });
      
      // Powiadom o usunięciu (pusty string)
      widget.onImageUpdated('');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zdjęcie profilowe zostało usunięte'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas usuwania zdjęcia: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = _buildFullImageUrl(widget.currentImageUrl);
    
    print('=== PROFILE IMAGE PICKER BUILD ===');
    print('Current image URL: ${widget.currentImageUrl}');
    print('Full image URL: $fullImageUrl');
    print('Cache key: $_cacheKey');
    print('Final URL: ${fullImageUrl.isNotEmpty ? '$fullImageUrl?v=$_cacheKey' : 'null'}');
    
    return GestureDetector(
      onTap: _isUploading ? null : _showImageSourceDialog,
      child: Stack(
        children: [
          // Zdjęcie profilowe
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      '$fullImageUrl?v=$_cacheKey',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      key: ValueKey('${widget.currentImageUrl}_$_cacheKey'),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey[400],
                    ),
            ),
          ),
          
          // Przycisk edycji / loading indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: _isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
