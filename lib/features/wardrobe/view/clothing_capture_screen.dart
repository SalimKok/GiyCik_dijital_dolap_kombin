import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/features/wardrobe/repository/clothing_repository.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/core/constants/api_constants.dart';

class ClothingCaptureScreen extends ConsumerStatefulWidget {
  final ClothingItem? existingItem;

  const ClothingCaptureScreen({
    super.key,
    this.existingItem,
  });

  @override
  ConsumerState<ClothingCaptureScreen> createState() => _ClothingCaptureScreenState();
}

class _ClothingCaptureScreenState extends ConsumerState<ClothingCaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  
  String? _selectedCategory = 'Üst';
  final List<String> _categories = ['Üst', 'Alt', 'Dış giyim', 'Ayakkabı', 'Aksesuar', 'Şal/Eşarp'];
  
  String? _selectedSeason = 'Mevsimlik';
  final List<String> _seasons = ['Yazlık', 'Kışlık', 'Mevsimlik'];
  
  File? _imageFile;
  String? _processedImageUrl; // DB url of the clean image
  final ImagePicker _picker = ImagePicker();
  
  bool _isAnalyzing = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!.name;
      _colorController.text = widget.existingItem!.color;
      
      if (_categories.contains(widget.existingItem!.category)) {
        _selectedCategory = widget.existingItem!.category;
      }
      if (_seasons.contains(widget.existingItem!.season)) {
        _selectedSeason = widget.existingItem!.season;
      }
      _processedImageUrl = widget.existingItem!.imageUrl;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _processedImageUrl = null;
        });
        await _analyzeAndAutoFill(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf seçilirken bir hata oluştu.')),
        );
      }
    }
  }

  Future<void> _analyzeAndAutoFill(String path) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await ref.read(clothingRepositoryProvider).analyzeClothingImage(path);
      // Expected result: {"url": "...", "analysis": {"category": "...", "color": "...", "season": "...", "name": "..."}}
      
      final url = result['url'] as String?;
      final analysis = result['analysis'] as Map<String, dynamic>?;

      if (mounted) {
        setState(() {
          _processedImageUrl = url;
          if (analysis != null) {
            _nameController.text = analysis['name'] ?? '';
            _colorController.text = analysis['color'] ?? '';
            
            final detectedCat = analysis['category'];
            if (detectedCat != null && _categories.contains(detectedCat)) {
              _selectedCategory = detectedCat;
            }
            
            final detectedSeason = analysis['season'];
            if (detectedSeason != null && _seasons.contains(detectedSeason)) {
              _selectedSeason = detectedSeason;
            }
          }
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yapay Zeka Analiz Hatası: $e')),
        );
      }
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });

    try {
      final newItem = ClothingItem(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _selectedCategory ?? 'Üst',
        color: _colorController.text.trim(),
        season: _selectedSeason ?? 'Mevsimlik',
        imageUrl: _processedImageUrl, // Already uploaded and background removed
      );

      if (widget.existingItem != null) {
        // Edit mode
        final updatedItem = newItem.copyWith(id: widget.existingItem!.id);
        await ref.read(wardrobeViewModelProvider.notifier).updateItem(updatedItem);
      } else {
        // Add mode
        await ref.read(wardrobeViewModelProvider.notifier).addItem(
          newItem, 
          imagePath: _processedImageUrl == null ? _imageFile?.path : null, 
        );
        // Hijyen listesini yenile (circular import yok, bu ekran her ikisine de erişebilir)
        ref.read(laundryViewModelProvider.notifier).loadItems();
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteItem() async {
    if (widget.existingItem == null) return;
    
    // Show confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kıyafeti Sil'),
        content: const Text('Bu kıyafeti silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref.read(wardrobeViewModelProvider.notifier).deleteItem(widget.existingItem!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final String? fullProcessedUrl = _processedImageUrl != null && _processedImageUrl!.isNotEmpty
        ? '${ApiConstants.baseUrl.replaceAll(RegExp(r'/api$'), '')}$_processedImageUrl'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingItem != null ? 'Kıyafeti Düzenle' : 'Yeni Kıyafet Ekle'),
      ),
      body: _isSaving || _isAnalyzing || _isDeleting
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _isAnalyzing ? 'Yapay zeka inceliyor...\nArka plan siliniyor...' : 
                  _isDeleting ? 'Siliniyor...' : 'Kaydediliyor...',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Kamerayla Çek'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Galeriden Seç'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        image: fullProcessedUrl != null
                            ? DecorationImage(
                                image: NetworkImage(fullProcessedUrl),
                                fit: BoxFit.contain, // Show whole clean item
                              )
                            : (_imageFile != null 
                                ? DecorationImage(
                                    image: FileImage(_imageFile!), 
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: _imageFile == null 
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 48, color: theme.colorScheme.primary),
                                const SizedBox(height: 8),
                                Text('Fotoğraf Ekle', style: TextStyle(color: theme.colorScheme.primary)),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Kıyafet Adı',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Kıyafet adı gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSeason,
                    decoration: const InputDecoration(
                      labelText: 'Mevsim',
                      border: OutlineInputBorder(),
                    ),
                    items: _seasons.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSeason = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Renk',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Renk gerekli' : null,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _saveItem,
                    child: Text(widget.existingItem != null ? 'Güncelle' : 'Kıyafeti Kaydet'),
                  ),
                  if (widget.existingItem != null) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _deleteItem,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Kıyafeti Sil'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
    );
  }
}