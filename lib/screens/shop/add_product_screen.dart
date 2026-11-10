import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_strings.dart';
import '../../models/product_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_toast.dart';
import '../../utils/image_pick.dart';

/// Product creation and edition, in one screen.
///
/// The two used to be two forms that drifted apart; passing [existing] switches
/// the labels and the submit path, so an edit can never miss a field the
/// creation form asks for.
class AddProductScreen extends StatefulWidget {
  final String shopId;

  /// The product being edited, or null to create a new one.
  final Product? existing;

  const AddProductScreen({super.key, required this.shopId, this.existing});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late bool _isNeuf;
  late bool _isNegotiable;
  late String _selectedCategoryId;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final product = widget.existing;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descController = TextEditingController(text: product?.description ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(0),
    );
    _isNeuf = product?.isNeuf ?? true;
    _isNegotiable = product?.isNegotiable ?? true;
    _selectedCategoryId = product?.categoryId ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isEmpty) return;

    final validFiles = <File>[];
    for (final x in images) {
      final file = File(x.path);
      if (!mounted) return;
      if (await validateImageFileSize(context, file)) {
        validFiles.add(file);
      }
    }

    if (validFiles.length > 10) {
      if (mounted) {
        AppToast.info(
          context.l10n.t('product.form.maxPhotos'),
          context: context,
        );
      }
    }

    if (validFiles.isNotEmpty && mounted) {
      setState(() {
        _selectedImages = validFiles.take(10).toList();
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
          context.l10n.t(
            _isEditing ? 'product.form.edit.title' : 'product.form.add.title',
          ),
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
                context.l10n.t('product.form.photos'),
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
                                alignment: Alignment.topCenter,
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
                    // Photos already stored on the product, so editing shows
                    // what the product looks like today.
                    if (_isEditing && widget.existing!.images.isNotEmpty)
                      for (final url in widget.existing!.images)
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
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
                              context.l10n.t('product.form.addPhoto'),
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
              _buildLabel(context.l10n.t('product.form.name')),
              const SizedBox(height: 8),
              _buildTextField(
                _nameController,
                context.l10n.t('product.form.nameHint'),
                maxLength: 20,
              ),

              const SizedBox(height: 20),

              // Description
              _buildLabel(context.l10n.t('product.form.description')),
              const SizedBox(height: 8),
              _buildTextField(
                _descController,
                context.l10n.t('product.form.descriptionHint'),
                maxLines: 3,
                maxLength: 1000,
              ),

              const SizedBox(height: 20),

              // Price
              _buildLabel(context.l10n.t('product.form.price')),
              const SizedBox(height: 8),
              _buildTextField(
                _priceController,
                '0.00',
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),

              const SizedBox(height: 20),

              // Category selector
              _buildLabel(context.l10n.t('product.form.category')),
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
                        context.l10n.t('product.form.categoryHint'),
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
              _buildLabel(context.l10n.t('product.form.condition')),
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
                            context.l10n.t('product.tag.neuf'),
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
                            context.l10n.t('product.tag.occasion'),
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

              const SizedBox(height: 20),

              // Negotiable price, shown as a badge next to the condition on
              // every product card.
              _buildLabel(context.l10n.t('product.form.priceLabel')),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildConditionButton(
                      label: context.l10n.t('product.form.negotiable'),
                      selected: _isNegotiable,
                      color: AppTheme.primary,
                      onTap: () => setState(() => _isNegotiable = true),
                    ),
                    _buildConditionButton(
                      label: context.l10n.t('product.form.fixedPrice'),
                      selected: !_isNegotiable,
                      color: AppTheme.textSecondary,
                      onTap: () => setState(() => _isNegotiable = false),
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
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.l10n.t(
                            _isEditing ? 'common.save' : 'product.form.publish',
                          ),
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

  /// One half of the Neuf / Occasion and Négociable / Prix fixe toggles.
  Widget _buildConditionButton({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
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
    int? maxLength,
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
        maxLength: maxLength,
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
            return context.l10n.t('product.form.required');
          }
          return null;
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    // Creating requires a photo; editing keeps the stored one when the
    // seller does not pick a new one.
    if (_selectedImages.isEmpty && !_isEditing) {
      AppToast.error(l10n.t('product.form.needPhoto'), context: context);
      return;
    }

    final parsedPrice = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    if (parsedPrice == null || parsedPrice < 0) {
      AppToast.error(l10n.t('product.form.required'), context: context);
      return;
    }

    final provider = context.read<AppProvider>();
    final navigator = Navigator.of(context);

    setState(() => _submitting = true);

    try {
      // Photos live on the phone until they are uploaded, and only the
      // returned URLs can be stored on the product. Every picked photo is
      // sent: the seller chose a gallery, and dropping all but the first is
      // what made the extra photos disappear.
      final galleryUrls = _selectedImages.isEmpty
          ? <String>[]
          : await provider.uploadImages(_selectedImages, folder: 'products');
      if (!mounted) return;

      if (_selectedImages.isNotEmpty && galleryUrls.isEmpty) {
        AppToast.error(
          provider.dataError ?? l10n.t('product.form.uploadFailed'),
          context: context,
        );
        return;
      }

      // The first photo is the cover; the gallery keeps every one of them,
      // cover included, so the carousel does not lose it.
      final coverUrl = galleryUrls.isEmpty ? '' : galleryUrls.first;

      final success = _isEditing
          ? await provider.updateProduct(
              widget.existing!.id,
              name: _nameController.text,
              description: _descController.text,
              price: parsedPrice,
              isNeuf: _isNeuf,
              isNegotiable: _isNegotiable,
              imageUrl: coverUrl.isEmpty ? null : coverUrl,
              imageUrls: galleryUrls.isEmpty ? null : galleryUrls,
              categoryId: _selectedCategoryId,
            )
          : await provider.addProduct(
              shopId: widget.shopId,
              name: _nameController.text,
              description: _descController.text,
              price: parsedPrice,
              isNeuf: _isNeuf,
              isNegotiable: _isNegotiable,
              imageUrl: coverUrl,
              imageUrls: galleryUrls,
              categoryId: _selectedCategoryId,
            );
      if (!mounted) return;

      if (!success) {
        AppToast.error(
          provider.dataError ?? l10n.t('product.form.publishFailed'),
          context: context,
        );
        return;
      }

      final successMsg = l10n.t(
        _isEditing ? 'product.form.updated' : 'product.form.published',
      );
      navigator.pop();
      AppToast.success(successMsg);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
