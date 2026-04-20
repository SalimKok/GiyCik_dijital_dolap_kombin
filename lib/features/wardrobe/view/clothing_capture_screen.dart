import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';

class ClothingCaptureScreen extends ConsumerStatefulWidget {
  const ClothingCaptureScreen({super.key});

  @override
  ConsumerState<ClothingCaptureScreen> createState() => _ClothingCaptureScreenState();
}

class _ClothingCaptureScreenState extends ConsumerState<ClothingCaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  
  String? _selectedCategory = 'Üst';
  final List<String> _categories = ['Üst', 'Alt', 'Dış giyim', 'Ayakkabı', 'Aksesuar'];
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  bool _isSaving = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle camera/gallery permission errors gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf eklenirken bir hata oluştu. İzinleri kontrol edin.')),
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
      );

      await ref.read(wardrobeViewModelProvider.notifier).addItem(
        newItem, 
        imagePath: _imageFile?.path,
      );

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

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kıyafet Ekle'),
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator())
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
                        image: _imageFile != null 
                            ? DecorationImage(
                                image: FileImage(_imageFile!), 
                                fit: BoxFit.cover,
                              )
                            : null,
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
                    child: const Text('Kıyafeti Kaydet'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}