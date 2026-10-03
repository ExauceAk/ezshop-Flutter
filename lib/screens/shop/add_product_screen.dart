import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  final String shopId;
  const AddProductScreen({super.key, required this.shopId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isNeuf = true;
  String _selectedCategoryId = '';
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((x) => File(x.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Ajouter un produit',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product images
              Text(
                'Photos du produit',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._selectedImages.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(entry.value),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeImage(entry.key),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primary, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Product name
              _buildLabel('Nom du produit'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'Ex: iPhone 14 Pro Max'),

              const SizedBox(height: 20),

              // Description
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(_descController, 'Décrivez votre produit...', maxLines: 3),

              const SizedBox(height: 20),

              // Price
              _buildLabel('Prix (\$)'),
              const SizedBox(height: 8),
              _buildTextField(_priceController, '0.00', keyboardType: TextInputType.number),

              const SizedBox(height: 20),

              // Category selector
              _buildLabel('Catégorie'),
              const SizedBox(height: 8),
              Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final categories = provider.categories;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
                      hint: Text(
                        'Choisir une catégorie',
                        style: GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 14),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textHint),
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id,
                          child: Text(
                            cat.name,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value ?? '');
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Condition toggle
              _buildLabel('État du produit'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNeuf = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isNeuf ? AppTheme.success : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Neuf',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: _isNeuf ? FontWeight.w700 : FontWeight.w500,
                              color: _isNeuf ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNeuf = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isNeuf ? AppTheme.warning : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Occasion',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: !_isNeuf ? FontWeight.w700 : FontWeight.w500,
                              color: !_isNeuf ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Publier le produit',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: AppTheme.textHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ce champ est requis';
          }
          return null;
        },
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez ajouter au moins une photo', style: GoogleFonts.poppins()),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      final provider = context.read<AppProvider>();

      // The photo lives on the phone until it is uploaded, and only the
      // returned URL can be stored on the product.
      final imageUrl = await provider.uploadImage(
        File(_selectedImages.first.path),
        folder: 'products',
      );
      if (!mounted) return;

      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.dataError ?? "La photo n'a pas pu être envoyée",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      final success = await provider.addProduct(
        shopId: widget.shopId,
        name: _nameController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        isNeuf: _isNeuf,
        imageUrl: imageUrl,
        categoryId: _selectedCategoryId,
      );
      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.dataError ?? 'Impossible de publier le produit',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit publié avec succès !', style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }
}
