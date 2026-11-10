/// A product shown in a theme preview.
///
/// The seller has not published anything yet when they pick a theme, so an
/// empty grid would make every theme look identical and give no idea of the
/// layout. These samples stand in for real products; the public storefront
/// never uses them.
class PreviewProduct {
  const PreviewProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.imageUrls = const [],
    this.oldPrice,
    this.isNeuf = true,
    this.isNegotiable = false,
    this.isAvailable = true,
    this.category = '',
  });

  final String name;
  final String description;

  /// Decimal string, exactly as the API stores it.
  final String price;
  final String? oldPrice;
  final String imageUrl;
  final List<String> imageUrls;
  final bool isNeuf;
  final bool isNegotiable;
  final bool isAvailable;
  final String category;

  List<String> get allImages {
    final result = <String>[];
    if (imageUrl.trim().isNotEmpty) {
      result.add(imageUrl.trim());
    }
    for (final url in imageUrls) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty && !result.contains(trimmed)) {
        result.add(trimmed);
      }
    }
    return result;
  }
}

/// Sample catalogue, mirroring the one the Next preview route uses so both
/// renderers show the exact same 6 realistic items.
const List<PreviewProduct> samplePreviewProducts = [
  PreviewProduct(
    name: 'Carafe Thermique Nordique',
    description:
        'Carafe isolante à double paroi en acier brossé et bouchon en chêne naturel, idéale pour conserver vos boissons chaudes ou fraîches toute la journée.',
    price: '14500',
    imageUrl:
        'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=800&q=80',
    ],
    isNeuf: true,
    isNegotiable: false,
    isAvailable: true,
    category: 'Art de la Table',
  ),
  PreviewProduct(
    name: 'Cocotte en Fonte Émaillée Alba',
    description:
        'Cocotte artisanale à diffusion thermique homogène pour mijoter, rôtir et servir directement à table avec élégance.',
    price: '28500',
    imageUrl:
        'https://images.unsplash.com/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=800&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1603199506016-b9a594b593c0?auto=format&fit=crop&w=800&q=80',
    ],
    isNeuf: true,
    isNegotiable: true,
    isAvailable: true,
    category: 'Cuisine',
  ),
  PreviewProduct(
    name: 'Lampe d’Ambiance Kanso',
    description:
        'Luminaire sculptural à lumière chaude tamisée, doté d’un variateur tactile et d’un socle en métal sablé.',
    price: '22000',
    imageUrl:
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=800&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80',
    ],
    isNeuf: true,
    isNegotiable: false,
    isAvailable: true,
    category: 'Luminaires',
  ),
  PreviewProduct(
    name: 'Plateau de Service Nami en Noyer',
    description:
        'Façonné dans une seule pièce de bois massif avec rebords adoucis à la main et finition à l’huile naturelle.',
    price: '11500',
    imageUrl:
        'https://images.unsplash.com/photo-1603199506016-b9a594b593c0?auto=format&fit=crop&w=800&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1603199506016-b9a594b593c0?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
    ],
    isNeuf: true,
    isNegotiable: true,
    isAvailable: true,
    category: 'Art de la Table',
  ),
  PreviewProduct(
    name: 'Vase Minéral en Grès Brut',
    description:
        'Pièce tournée à la main présentant une texture sablée naturelle, pensée pour accueillir bouquets secs ou fleurs fraîches.',
    price: '16900',
    imageUrl:
        'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=800&q=80',
    ],
    isNeuf: false,
    isNegotiable: true,
    isAvailable: true,
    category: 'Décoration',
  ),
  PreviewProduct(
    name: 'Coffret Infusion & Céramique',
    description:
        'Assortiment de deux tasses en grès émaillé accompagnées de leur infuseur en inox fin.',
    price: '19500',
    imageUrl:
        'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=800&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=800&q=80',
    ],
    isNeuf: true,
    isNegotiable: false,
    isAvailable: true,
    category: 'Art de la Table',
  ),
];
