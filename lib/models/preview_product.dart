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
    this.oldPrice,
    this.isNeuf = true,
    this.isAvailable = true,
    this.category = '',
  });

  final String name;
  final String description;

  /// Decimal string, exactly as the API stores it.
  final String price;
  final String? oldPrice;
  final String imageUrl;
  final bool isNeuf;
  final bool isAvailable;
  final String category;
}

/// Sample catalogue, mirroring the one the Next preview route uses so both
/// renderers show the same thing.
const List<PreviewProduct> samplePreviewProducts = [
  PreviewProduct(
    name: 'Bouteille Nordique',
    description:
        'Une bouteille réutilisable en acier inoxydable, pensée pour accompagner vos journées.',
    price: '4385',
    imageUrl:
        'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=600&q=80',
    category: 'Maison',
  ),
  PreviewProduct(
    name: 'Cocotte Alba',
    description:
        'Une cocotte compacte au design intemporel pour préparer facilement vos plats.',
    price: '7835',
    oldPrice: '9000',
    imageUrl:
        'https://images.unsplash.com/photo-1584990347449-ae9f6c4d4a3f?auto=format&fit=crop&w=600&q=80',
    category: 'Cuisine',
  ),
  PreviewProduct(
    name: 'Lampe Kanso',
    description:
        'Une lampe douce et chaleureuse pour créer une ambiance apaisante dans votre intérieur.',
    price: '8990',
    imageUrl:
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=600&q=80',
    isNeuf: false,
    category: 'Décoration',
  ),
  PreviewProduct(
    name: 'Plateau Nami',
    description:
        'Un plateau en bois aux lignes sobres, idéal pour servir le petit déjeuner ou vos boissons.',
    price: '3450',
    imageUrl:
        'https://images.unsplash.com/photo-1603199506016-b9a594b593c0?auto=format&fit=crop&w=600&q=80',
    isAvailable: false,
    category: 'Maison',
  ),
];