import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _subdomainController = TextEditingController();
  String _selectedTemplate = 'default';
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _templates = [
    {'id': 'default', 'name': 'Standard', 'description': 'Design épuré et classique', 'image': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=300&h=200&fit=crop'},
    {'id': 'fashion', 'name': 'Mode', 'description': 'Élégant pour la mode', 'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300&h=200&fit=crop'},
    {'id': 'beauty', 'name': 'Beauté', 'description': 'Luxe et raffiné', 'image': 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=300&h=200&fit=crop'},
    {'id': 'tech', 'name': 'Tech', 'description': 'Moderne et high-tech', 'image': 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=300&h=200&fit=crop'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _whatsappController.dispose();
    _subdomainController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (image != null) {
      setState(() => _logoFile = File(image.path));
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final whatsappLink = _whatsappController.text.isNotEmpty
        ? 'https://wa.me/${_whatsappController.text.replaceAll(RegExp(r'[^0-9]'), '')}'
        : '';

    final success = provider.createShop(
      name: _nameController.text,
      description: _descController.text,
      whatsappLink: whatsappLink,
      template: _selectedTemplate,
      subdomain: _subdomainController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Boutique créée avec succès ! 🎉'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showTemplatePreview(String templateId) {
    final template = _templates.firstWhere((t) => t['id'] == templateId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textHint.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Template ${template['name']}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          template['description']!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // WebView preview
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadHtmlString(_getTemplatePreviewHtml(templateId)),
                    ),
                  ),
                ),
              ),
              // Select button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedTemplate = templateId);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Sélectionner ce template',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Créer ma boutique', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 40, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      'Configurez votre boutique',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    Text(
                      'Remplissez les informations ci-dessous',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Logo ───
              _buildLabel('Logo de la boutique'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _logoFile != null ? AppTheme.primary : AppTheme.border,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: _logoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(_logoFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, color: AppTheme.textHint, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              'Ajouter',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textHint),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Name ───
              _buildLabel('Nom de la boutique'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Ma Boutique'),
                validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 20),

              // ─── Description ───
              _buildLabel('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Décrivez votre boutique...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
              ),
              const SizedBox(height: 20),

              // ─── WhatsApp ───
              _buildLabel('Lien WhatsApp (optionnel)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+212 6XX XXX XXX',
                  prefixIcon: Icon(Icons.phone_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Subdomain ───
              _buildLabel('Sous-domaine de votre boutique web'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subdomainController,
                      textCapitalization: TextCapitalization.none,
                      decoration: const InputDecoration(hintText: 'ma-boutique'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Sous-domaine requis';
                        if (!RegExp(r'^[a-z0-9-]+$').hasMatch(v)) return 'Minuscules, chiffres et tirets uniquement';
                        return null;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                    ),
                    child: Text(
                      '.mackettttz.test',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Template Selection ───
              _buildLabel('Template de la boutique web'),
              const SizedBox(height: 4),
              Text(
                'Glissez pour voir les templates, appuyez pour prévisualiser',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textHint,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _templates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    final isSelected = template['id'] == _selectedTemplate;
                    return GestureDetector(
                      onTap: () => _showTemplatePreview(template['id']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Template preview image
                            Stack(
                              children: [
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    child: Image.network(
                                      template['image']!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppTheme.primary.withOpacity(0.1),
                                        child: Center(
                                          child: Icon(
                                            _getTemplateIcon(template['id']!),
                                            color: AppTheme.primary,
                                            size: 36,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                                    ),
                                  ),
                                // Preview icon overlay
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.visibility_rounded, color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                            // Template info
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template['name']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    template['description']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ─── Submit ───
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(
                    'Créer ma boutique',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
    );
  }

  IconData _getTemplateIcon(String templateId) {
    switch (templateId) {
      case 'fashion':
        return Icons.checkroom_rounded;
      case 'beauty':
        return Icons.spa_rounded;
      case 'tech':
        return Icons.devices_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  String _getTemplatePreviewHtml(String templateId) {
    final colors = {
      'default': {'bg': '#F8F9FE', 'primary': '#6C5CE7', 'text': '#2D3436'},
      'fashion': {'bg': '#FFF5F7', 'primary': '#E85D75', 'text': '#2D3436'},
      'beauty': {'bg': '#FFF8F0', 'primary': '#F5A623', 'text': '#2D3436'},
      'tech': {'bg': '#F0F4FF', 'primary': '#4A90D9', 'text': '#2D3436'},
    };
    final c = colors[templateId]!;

    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, sans-serif; background: ${c['bg']}; }
        .header { background: ${c['primary']}; padding: 20px; text-align: center; }
        .header h1 { color: white; font-size: 18px; }
        .header p { color: rgba(255,255,255,0.8); font-size: 12px; margin-top: 4px; }
        .products { padding: 12px; display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
        .product { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 6px rgba(0,0,0,0.05); }
        .product-img { height: 80px; background: #F1F3F5; }
        .product-info { padding: 8px; }
        .product-name { font-size: 11px; font-weight: 600; color: ${c['text']}; }
        .product-price { font-size: 12px; font-weight: 700; color: ${c['primary']}; margin-top: 2px; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>${_nameController.text.isNotEmpty ? _nameController.text : 'Votre Boutique'}</h1>
        <p>${_descController.text.isNotEmpty ? _descController.text : 'Description de la boutique'}</p>
      </div>
      <div class="products">
        <div class="product">
          <div class="product-img"></div>
          <div class="product-info">
            <div class="product-name">Produit 1</div>
            <div class="product-price">29.99 MAD</div>
          </div>
        </div>
        <div class="product">
          <div class="product-img"></div>
          <div class="product-info">
            <div class="product-name">Produit 2</div>
            <div class="product-price">49.99 MAD</div>
          </div>
        </div>
        <div class="product">
          <div class="product-img"></div>
          <div class="product-info">
            <div class="product-name">Produit 3</div>
            <div class="product-price">19.99 MAD</div>
          </div>
        </div>
        <div class="product">
          <div class="product-img"></div>
          <div class="product-info">
            <div class="product-name">Produit 4</div>
            <div class="product-price">89.99 MAD</div>
          </div>
        </div>
      </div>
    </body>
    </html>
    ''';
  }
}
