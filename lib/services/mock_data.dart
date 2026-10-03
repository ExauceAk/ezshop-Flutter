import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/user_model.dart';

class MockData {
  // ─── Categories ───
  static final List<Category> categories = [
    const Category(id: 'cat1', name: 'Électronique', icon: 'phone_ipad', color: '#4A90D9'),
    const Category(id: 'cat2', name: 'Mode', icon: 'checkroom', color: '#E85D75'),
    const Category(id: 'cat3', name: 'Maison', icon: 'chair', color: '#6BC5A0'),
    const Category(id: 'cat4', name: 'Beauté', icon: 'spa', color: '#F5A623'),
    const Category(id: 'cat5', name: 'Sport', icon: 'fitness_center', color: '#7B61FF'),
    const Category(id: 'cat6', name: 'Véhicules', icon: 'directions_car', color: '#FF6B35'),
    const Category(id: 'cat7', name: 'Livres', icon: 'menu_book', color: '#4ECDC4'),
    const Category(id: 'cat8', name: 'Alimentaire', icon: 'restaurant', color: '#C0392B'),
  ];

  // ─── Mock Shops ───
  static final List<Shop> shops = [
    Shop(
      id: 'shop1', name: 'TechZone',
      description: 'La référence en électronique et gadgets high-tech.',
      ownerId: 'user2', rating: 4.7, productCount: 120,
      createdAt: DateTime(2024, 1, 15),
      whatsappLink: 'https://wa.me/212600000001', theme: 'atelier', subdomain: 'techzone',
    ),
    Shop(
      id: 'shop2', name: 'Style & Co',
      description: 'Mode tendance pour hommes et femmes.',
      ownerId: 'user3', rating: 4.5, productCount: 85,
      createdAt: DateTime(2024, 3, 10),
      whatsappLink: 'https://wa.me/212600000002', theme: 'vitrine', subdomain: 'styleco',
    ),
    Shop(
      id: 'shop3', name: 'HomeDesign',
      description: 'Décoration et mobilier pour votre intérieur.',
      ownerId: 'user4', rating: 4.8, productCount: 64,
      createdAt: DateTime(2024, 2, 20),
      whatsappLink: 'https://wa.me/212600000003', theme: 'annuaire', subdomain: 'homedesign',
    ),
    Shop(
      id: 'shop4', name: 'BeautyHub',
      description: 'Produits de beauté et soins personnalisés.',
      ownerId: 'user5', rating: 4.6, productCount: 95,
      createdAt: DateTime(2024, 4, 5),
      whatsappLink: 'https://wa.me/212600000004', theme: 'editorial', subdomain: 'beautyhub',
    ),
    Shop(
      id: 'shop5', name: 'SportMax',
      description: 'Équipements sportifs et vêtements techniques.',
      ownerId: 'user6', rating: 4.4, productCount: 72,
      createdAt: DateTime(2024, 5, 1),
      whatsappLink: 'https://wa.me/212600000005', theme: 'nocturne', subdomain: 'sportmax',
    ),
  ];

  // ─── Mock Users ───
  static final List<UserModel> users = [
    UserModel(id: 'user1', name: 'Utilisateur Demo', email: 'demo@market.com', phone: '+33 6 12 34 56 78', address: '123 Rue de Paris, 75001'),
    UserModel(id: 'user2', name: 'Ahmed Benali', email: 'ahmed@techzone.com'),
    UserModel(id: 'user3', name: 'Sara Meziane', email: 'sara@styleco.com'),
    UserModel(id: 'user4', name: 'Karim Dupont', email: 'karim@homedesign.com'),
    UserModel(id: 'user5', name: 'Lina Ferrer', email: 'lina@beautyhub.com'),
    UserModel(id: 'user6', name: 'Omar Sy', email: 'omar@sportmax.com'),
  ];

  // ─── Mock Products ───
  static final List<Product> products = [
    Product(
      id: 'prod1', name: 'iPhone 15 Pro Max',
      description: 'Le dernier iPhone avec puce A17 Pro, écran 6.7" Super Retina XDR. Design en titane.',
      price: 1199.99, oldPrice: 1299.99,
      imageUrl: 'https://picsum.photos/400/400?random=1',
      imageUrls: [
        'https://picsum.photos/400/400?random=1',
        'https://picsum.photos/400/400?random=101',
        'https://picsum.photos/400/400?random=201',
        'https://picsum.photos/400/400?random=301',
      ],
      categoryId: 'cat1', shopId: 'shop1', sellerName: 'TechZone',
      rating: 4.8, reviewCount: 342, isNeuf: true,
    ),
    Product(
      id: 'prod2', name: 'MacBook Air M3',
      description: 'Ordinateur portable ultraléger avec puce M3, 15" Liquid Retina.',
      price: 1499.99,
      imageUrl: 'https://picsum.photos/400/400?random=2',
      imageUrls: [
        'https://picsum.photos/400/400?random=2',
        'https://picsum.photos/400/400?random=102',
        'https://picsum.photos/400/400?random=202',
      ],
      categoryId: 'cat1', shopId: 'shop1', sellerName: 'TechZone',
      rating: 4.9, reviewCount: 189, isNeuf: true,
    ),
    Product(
      id: 'prod3', name: "Robe d'été florale",
      description: "Robe légère en coton avec motif fleuri. Parfaite pour l'été.",
      price: 49.99, oldPrice: 79.99,
      imageUrl: 'https://picsum.photos/400/400?random=3',
      imageUrls: [
        'https://picsum.photos/400/400?random=3',
        'https://picsum.photos/400/400?random=103',
        'https://picsum.photos/400/400?random=203',
      ],
      categoryId: 'cat2', shopId: 'shop2', sellerName: 'Style & Co',
      rating: 4.3, reviewCount: 87, isNeuf: false,
    ),
    Product(
      id: 'prod4', name: 'Canapé scandinave',
      description: 'Canapé 3 places en tissu gris, style scandinave épuré.',
      price: 899.99,
      imageUrl: 'https://picsum.photos/400/400?random=4',
      imageUrls: [
        'https://picsum.photos/400/400?random=4',
        'https://picsum.photos/400/400?random=104',
      ],
      categoryId: 'cat3', shopId: 'shop3', sellerName: 'HomeDesign',
      rating: 4.7, reviewCount: 56, isNeuf: true,
    ),
    Product(
      id: 'prod5', name: 'Sérum Vitamine C',
      description: 'Sérum éclaircissant à la vitamine C. Éclat et protection.',
      price: 29.99, oldPrice: 39.99,
      imageUrl: 'https://picsum.photos/400/400?random=5',
      imageUrls: [
        'https://picsum.photos/400/400?random=5',
        'https://picsum.photos/400/400?random=105',
        'https://picsum.photos/400/400?random=205',
      ],
      categoryId: 'cat4', shopId: 'shop4', sellerName: 'BeautyHub',
      rating: 4.6, reviewCount: 234, isNeuf: true,
    ),
    Product(
      id: 'prod6', name: 'Yoga Mat Premium',
      description: 'Tapis de yoga antidérapant, épaisseur 6mm, sac de transport inclus.',
      price: 39.99,
      imageUrl: 'https://picsum.photos/400/400?random=6',
      imageUrls: [
        'https://picsum.photos/400/400?random=6',
        'https://picsum.photos/400/400?random=106',
      ],
      categoryId: 'cat5', shopId: 'shop5', sellerName: 'SportMax',
      rating: 4.4, reviewCount: 123, isNeuf: true,
    ),
    Product(
      id: 'prod7', name: 'Samsung Galaxy S24 Ultra',
      description: 'Smartphone 6.8", S Pen intégré, IA Galaxy. Le meilleur Samsung.',
      price: 1399.99, oldPrice: 1499.99,
      imageUrl: 'https://picsum.photos/400/400?random=7',
      imageUrls: [
        'https://picsum.photos/400/400?random=7',
        'https://picsum.photos/400/400?random=107',
        'https://picsum.photos/400/400?random=207',
        'https://picsum.photos/400/400?random=307',
      ],
      categoryId: 'cat1', shopId: 'shop1', sellerName: 'TechZone',
      rating: 4.7, reviewCount: 267, isNeuf: true,
    ),
    Product(
      id: 'prod8', name: 'Veste en cuir premium',
      description: 'Veste en cuir véritable, coupe ajustée, doublure en soie.',
      price: 199.99,
      imageUrl: 'https://picsum.photos/400/400?random=8',
      imageUrls: [
        'https://picsum.photos/400/400?random=8',
        'https://picsum.photos/400/400?random=108',
      ],
      categoryId: 'cat2', shopId: 'shop2', sellerName: 'Style & Co',
      rating: 4.5, reviewCount: 45, isNeuf: false,
    ),
    Product(
      id: 'prod9', name: 'Lampe design LED',
      description: "Lampe de table LED avec variation d'intensité et de température.",
      price: 59.99,
      imageUrl: 'https://picsum.photos/400/400?random=9',
      imageUrls: [
        'https://picsum.photos/400/400?random=9',
        'https://picsum.photos/400/400?random=109',
        'https://picsum.photos/400/400?random=209',
      ],
      categoryId: 'cat3', shopId: 'shop3', sellerName: 'HomeDesign',
      rating: 4.6, reviewCount: 78, isNeuf: true,
    ),
    Product(
      id: 'prod10', name: 'Parfum Océan',
      description: "Eau de toilette marine, notes d'agrumes et de bois de santal.",
      price: 65.00, oldPrice: 85.00,
      imageUrl: 'https://picsum.photos/400/400?random=10',
      imageUrls: [
        'https://picsum.photos/400/400?random=10',
        'https://picsum.photos/400/400?random=110',
      ],
      categoryId: 'cat4', shopId: 'shop4', sellerName: 'BeautyHub',
      rating: 4.8, reviewCount: 156, isNeuf: false,
    ),
    Product(
      id: 'prod11', name: 'Chaussures Running',
      description: 'Chaussures de course légères avec amorti réactif.',
      price: 129.99,
      imageUrl: 'https://picsum.photos/400/400?random=11',
      imageUrls: [
        'https://picsum.photos/400/400?random=11',
        'https://picsum.photos/400/400?random=111',
        'https://picsum.photos/400/400?random=211',
      ],
      categoryId: 'cat5', shopId: 'shop5', sellerName: 'SportMax',
      rating: 4.5, reviewCount: 198, isNeuf: true,
    ),
    Product(
      id: 'prod12', name: 'Casque Sony WH-1000XM5',
      description: 'Casque sans fil à réduction de bruit active. Son exceptionnel.',
      price: 349.99, oldPrice: 399.99,
      imageUrl: 'https://picsum.photos/400/400?random=12',
      imageUrls: [
        'https://picsum.photos/400/400?random=12',
        'https://picsum.photos/400/400?random=112',
      ],
      categoryId: 'cat1', shopId: 'shop1', sellerName: 'TechZone',
      rating: 4.9, reviewCount: 412, isNeuf: false,
    ),
    Product(
      id: 'prod13', name: 'Sac à main cuir',
      description: 'Sac à main en cuir véritable, intérieur doublé, multiples compartiments.',
      price: 89.99,
      imageUrl: 'https://picsum.photos/400/400?random=13',
      imageUrls: [
        'https://picsum.photos/400/400?random=13',
        'https://picsum.photos/400/400?random=113',
      ],
      categoryId: 'cat2', shopId: 'shop2', sellerName: 'Style & Co',
      rating: 4.4, reviewCount: 67, isNeuf: false,
    ),
    Product(
      id: 'prod14', name: 'Ensemble meubles TV',
      description: 'Meuble TV moderne en chêne massif, 2 portes et 3 tiroirs.',
      price: 349.99,
      imageUrl: 'https://picsum.photos/400/400?random=14',
      imageUrls: [
        'https://picsum.photos/400/400?random=14',
        'https://picsum.photos/400/400?random=114',
        'https://picsum.photos/400/400?random=214',
      ],
      categoryId: 'cat3', shopId: 'shop3', sellerName: 'HomeDesign',
      rating: 4.7, reviewCount: 34, isNeuf: true,
    ),
    Product(
      id: 'prod15', name: 'Pack Maquillage Pro',
      description: 'Kit complet maquillage professionnel : fond de teint, poudres, fards.',
      price: 149.99, oldPrice: 199.99,
      imageUrl: 'https://picsum.photos/400/400?random=15',
      imageUrls: [
        'https://picsum.photos/400/400?random=15',
        'https://picsum.photos/400/400?random=115',
      ],
      categoryId: 'cat4', shopId: 'shop4', sellerName: 'BeautyHub',
      rating: 4.7, reviewCount: 189, isNeuf: true,
    ),
    Product(
      id: 'prod16', name: 'Vélo électrique',
      description: 'Vélo à assistance électrique, autonomie 60km, pliable.',
      price: 799.99,
      imageUrl: 'https://picsum.photos/400/400?random=16',
      imageUrls: [
        'https://picsum.photos/400/400?random=16',
        'https://picsum.photos/400/400?random=116',
        'https://picsum.photos/400/400?random=216',
      ],
      categoryId: 'cat5', shopId: 'shop5', sellerName: 'SportMax',
      rating: 4.3, reviewCount: 45, isNeuf: false,
    ),
    Product(
      id: 'prod17', name: 'iPad Pro M4',
      description: 'Tablette iPad Pro 11" avec puce M4, écran OLED tandem.',
      price: 1099.99,
      imageUrl: 'https://picsum.photos/400/400?random=17',
      imageUrls: [
        'https://picsum.photos/400/400?random=17',
        'https://picsum.photos/400/400?random=117',
        'https://picsum.photos/400/400?random=217',
      ],
      categoryId: 'cat1', shopId: 'shop1', sellerName: 'TechZone',
      rating: 4.8, reviewCount: 156, isNeuf: true,
    ),
    Product(
      id: 'prod18', name: 'Montre connectée sport',
      description: 'Montre GPS avec oxymètre, suivi cardiac, étanche 50m.',
      price: 249.99, oldPrice: 299.99,
      imageUrl: 'https://picsum.photos/400/400?random=18',
      imageUrls: [
        'https://picsum.photos/400/400?random=18',
        'https://picsum.photos/400/400?random=118',
      ],
      categoryId: 'cat1', shopId: 'shop1', sellerName: 'TechZone',
      rating: 4.6, reviewCount: 234, isNeuf: false,
    ),
    // ─── Additional products ───
    Product(
      id: 'prod19', name: 'Robot aspirateur intelligent',
      description: 'Robot aspirateur avec cartographie laser, vidage automatique.',
      price: 449.99,
      imageUrl: 'https://picsum.photos/400/400?random=19',
      imageUrls: [
        'https://picsum.photos/400/400?random=19',
        'https://picsum.photos/400/400?random=119',
      ],
      categoryId: 'cat1', shopId: 'shop1', sellerName: 'TechZone',
      rating: 4.5, reviewCount: 178, isNeuf: true,
    ),
    Product(
      id: 'prod20', name: 'Sneakers Limited Edition',
      description: 'Baskets édition limitée, cuir et mesh, semelle confort.',
      price: 189.99,
      imageUrl: 'https://picsum.photos/400/400?random=20',
      imageUrls: [
        'https://picsum.photos/400/400?random=20',
        'https://picsum.photos/400/400?random=120',
        'https://picsum.photos/400/400?random=220',
      ],
      categoryId: 'cat2', shopId: 'shop2', sellerName: 'Style & Co',
      rating: 4.7, reviewCount: 92, isNeuf: true,
    ),
    Product(
      id: 'prod21', name: 'Ensemble vaisselle porcelaine',
      description: 'Service à 24 pièces, porcelaine fine, motif moderne.',
      price: 129.99,
      imageUrl: 'https://picsum.photos/400/400?random=21',
      imageUrls: [
        'https://picsum.photos/400/400?random=21',
        'https://picsum.photos/400/400?random=121',
      ],
      categoryId: 'cat3', shopId: 'shop3', sellerName: 'HomeDesign',
      rating: 4.6, reviewCount: 45, isNeuf: true,
    ),
    Product(
      id: 'prod22', name: 'Couleur cheveux Bio',
      description: "Coloration naturelle sans ammoniaque, 12 teintes disponibles.",
      price: 24.99,
      imageUrl: 'https://picsum.photos/400/400?random=22',
      imageUrls: [
        'https://picsum.photos/400/400?random=22',
        'https://picsum.photos/400/400?random=122',
      ],
      categoryId: 'cat4', shopId: 'shop4', sellerName: 'BeautyHub',
      rating: 4.4, reviewCount: 156, isNeuf: true,
    ),
    Product(
      id: 'prod23', name: 'Kettlebell adjustable',
      description: 'Kettlebell ajustable 5-20kg, pour home gym.',
      price: 89.99,
      imageUrl: 'https://picsum.photos/400/400?random=23',
      imageUrls: [
        'https://picsum.photos/400/400?random=23',
        'https://picsum.photos/400/400?random=123',
      ],
      categoryId: 'cat5', shopId: 'shop5', sellerName: 'SportMax',
      rating: 4.5, reviewCount: 67, isNeuf: true,
    ),
    Product(
      id: 'prod24', name: 'Pantalon cargo homme',
      description: 'Pantalon cargo confortable, multiple poches, coton stretch.',
      price: 59.99, oldPrice: 79.99,
      imageUrl: 'https://picsum.photos/400/400?random=24',
      imageUrls: [
        'https://picsum.photos/400/400?random=24',
        'https://picsum.photos/400/400?random=124',
      ],
      categoryId: 'cat2', shopId: 'shop2', sellerName: 'Style & Co',
      rating: 4.3, reviewCount: 34, isNeuf: false,
    ),
  ];
}
