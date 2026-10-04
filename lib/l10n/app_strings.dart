import 'package:flutter/widgets.dart';

/// Languages the interface is available in.
///
/// Adding one is three steps: add the value here, add its entry to
/// [AppStrings.translations], and add it to the list offered on the language
/// screen. Nothing else in the app has to change.
enum AppLanguage {
  fr,
  en;

  /// Name shown in the language picker, always in its own language so a user
  /// who lost their way can still find theirs.
  String get nativeName => switch (this) {
        AppLanguage.fr => 'Français',
        AppLanguage.en => 'English',
      };

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.name == code,
      orElse: () => AppLanguage.fr,
    );
  }
}

/// Every static string of the interface, keyed.
///
/// Values may contain `{placeholders}`, replaced by [t] from its arguments.
///
/// French is the reference: a key missing from another language falls back to
/// it, so a half-translated language degrades to French instead of showing a
/// raw key to the user.
class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  static const Map<AppLanguage, Map<String, String>> translations = {
    AppLanguage.fr: _fr,
    AppLanguage.en: _en,
  };

  /// Resolves a key in the current language.
  ///
  /// `t('shop.orders')` and `t('greeting', {'name': 'Joh'})` both work; an
  /// unknown key returns itself, which makes a missing entry obvious in the
  /// interface instead of crashing the screen.
  String t(String key, [Map<String, String> params = const {}]) {
    final table = translations[language] ?? const <String, String>{};
    var value = table[key] ?? _fr[key] ?? key;

    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }

    return value;
  }

  // ═══════════════════════════════════
  //  FRANÇAIS (référence)
  // ═══════════════════════════════════

  static const Map<String, String> _fr = {
    // ─── Common ───
    'common.cancel': 'Annuler',
    'common.save': 'Enregistrer',
    'common.retry': 'Réessayer',
    'common.back': 'Retour',
    'common.loading': 'Chargement…',
    'common.delete': 'Supprimer',
    'common.edit': 'Modifier',

    // ─── Auth ───
    'auth.login.title': 'Connexion',
    'auth.login.subtitle': 'Connectez-vous pour acheter et vendre',
    'auth.login.email': 'Adresse e-mail',
    'auth.login.password': 'Mot de passe',
    'auth.login.cta': 'Se connecter',
    'auth.login.forgot': 'Mot de passe oublié ?',
    'auth.login.noAccount': 'Pas encore de compte ?',
    'auth.login.createAccount': "S'inscrire",
    'auth.signup.title': 'Créer un compte',
    'auth.signup.subtitle': 'Rejoignez notre marketplace et commencez à acheter/vendre',
    'auth.signup.name': 'Nom complet',
    'auth.signup.confirm': 'Confirmer le mot de passe',
    'auth.signup.cta': 'Créer mon compte',
    'auth.signup.haveAccount': 'Vous avez déjà un compte ?',
    'auth.forgot.title': 'Mot de passe oublié',
    'auth.forgot.subtitle':
        'Indiquez votre e-mail, nous vous enverrons un lien de réinitialisation.',
    'auth.forgot.cta': 'Envoyer le lien',
    'auth.forgot.sent': 'Si un compte existe, un e-mail vient d\'être envoyé.',
    'auth.forgot.backToLogin': 'Retour à la connexion',

    // ─── Navigation ───
    'nav.home': 'Accueil',
    'nav.search': 'Rechercher',
    'nav.shops': 'Boutiques',
    'nav.favorites': 'Favoris',
    'nav.profile': 'Profil',

    // ─── Home ───
    'home.guest': 'Invité',
    'home.banner.tag': '🏪 EZ Shop',
    'home.banner.title': 'Créez votre propre boutique',
    'home.banner.subtitle': 'Proposez vos produits et vendez en ligne',
    'home.banner.cta': 'Commencer →',
    'home.filter.all': 'Tous',
    'home.filter.neuf': 'Neuf',
    'home.filter.occasion': 'Occasion',
    'home.products': 'Produits',
    'home.products.empty': 'Aucun produit',
    'home.shops.popular': 'Boutiques populaires',

    // ─── Search ───
    'search.hint': 'Rechercher…',
    'search.empty.title': 'Aucun résultat trouvé',
    'search.empty.subtitle': 'Essayez avec d\'autres mots-clés',

    // ─── Favorites ───
    'favorites.title': 'Mes Favoris',
    'favorites.empty.title': 'Aucun favori pour le moment',
    'favorites.empty.subtitle': 'Appuyez sur ♡ pour ajouter un produit',

    // ─── Profile ───
    'profile.title': 'Mon Profil',
    'profile.guest': 'Invité',
    'profile.settings': 'Paramètres',
    'profile.menu.shops': 'Mes boutiques',
    'profile.menu.orders': 'Mes Commandes',
    'profile.menu.favorites': 'Mes Favoris',
    'profile.menu.validation': 'Validation',
    'profile.menu.language': 'Langue',
    'profile.menu.notifications': 'Notifications',
    'profile.menu.help': 'Aide & Support',
    'profile.menu.about': 'À propos',
    'profile.logout': 'Se déconnecter',
    'profile.edit.title': 'Modifier le profil',
    'profile.edit.name': 'Nom',
    'profile.edit.nameHint': 'Votre nom',
    'profile.edit.phone': 'Téléphone',
    'profile.edit.phoneHint': '+33 6 00 00 00 00',
    'profile.edit.address': 'Adresse',
    'profile.edit.addressHint': 'Votre adresse',
    'profile.edit.saved': 'Profil mis à jour',
    'profile.edit.failed': 'Impossible d\'enregistrer',
    'profile.orders.title': 'Commandes reçues',
    'profile.orders.empty': 'Aucune commande reçue',
    'profile.avatar.updated': 'Photo de profil mise à jour',
    'profile.avatar.failed': 'Photo non enregistrée',
    'profile.avatar.cropTitle': 'Photo de profil',

    // ─── Product ───
    'product.tag.neuf': 'Neuf',
    'product.tag.occasion': 'Occasion',
    'product.tag.negotiable': 'Négociable',
    'product.tag.fixedPrice': 'Prix fixe',
    'product.description': 'Description',
    'product.soldBy': 'Vendu par',
    'product.rate': '• Noter',
    'product.noReviews': 'Pas encore d\'avis',
    'product.negotiableHint': 'Prix négociable : faites votre offre sur WhatsApp.',
    'product.orderWhatsapp': 'Commander via WhatsApp',
    'product.unknownShop': 'Boutique inconnue',
    'product.noWhatsapp':
        'WhatsApp indisponible : cette boutique n\'a pas renseigné de numéro.',
    'product.orderAlreadyRecorded': 'Commande déjà enregistrée pour aujourd\'hui',
    'product.orderFailed': 'Commande non enregistrée',
    'product.whatsappMessage':
        'Bonjour, je suis intéressé par votre produit « {name} » à {price}, trouvé sur EZ Shop.',

    // ─── Shop rating ───
    'rating.new': 'Noter la boutique',
    'rating.edit': 'Modifier votre note',
    'rating.send': 'Envoyer ma note',
    'rating.update': 'Mettre à jour',
    'rating.none': 'Aucun avis pour le moment',
    'rating.summary': '{average} / 5 • {count} avis',
    'rating.hint':
        'Une seule note par boutique : vous pouvez la modifier à tout moment.',
    'rating.thanks': 'Merci pour votre note !',
    'rating.updated': 'Votre note a été mise à jour',
    'rating.failed': 'Impossible d\'enregistrer votre note',

    // ─── Shops ───
    'shop.list.title': 'Mes boutiques',
    'shop.list.new': 'Nouvelle boutique',
    'shop.detail.personalise': 'Personnaliser la boutique',
    'shop.detail.stats.products': 'Produits',
    'shop.detail.stats.orders': 'Commandes',
    'shop.detail.stats.rating': 'Note',
    'shop.detail.boost.title': 'Boostez vos ventes',
    'shop.detail.boost.subtitle':
        'Mettez vos produits en avant et attirez plus de clients.',
    'shop.detail.orders.title': 'Commandes reçues',
    'shop.detail.danger.title': 'Zone sensible',
    'shop.detail.danger.delete': 'Supprimer cette boutique',
    'shop.detail.danger.done': 'Boutique supprimée',
    'shop.detail.danger.failed': 'Suppression impossible',
    'shop.detail.delete.title': 'Supprimer la boutique ?',
    'shop.detail.delete.body':
        '« {name} » sera supprimée, ainsi que tout ce qui en dépend :',
    'shop.detail.delete.unknownCounts':
        'Impossible de compter ce qui sera supprimé. Réessayez avant de confirmer.',
    'shop.detail.delete.products': '{count} produit(s)',
    'shop.detail.delete.orders': '{count} commande(s) reçue(s)',
    'shop.detail.delete.ratings': '{count} avis',
    'shop.detail.delete.confirmLabel':
        'Tapez « {name} » pour confirmer. Cette action est définitive.',
    'shop.detail.delete.confirm': 'Supprimer définitivement',
    'shop.detail.orders.empty': 'Aucune commande pour l\'instant.',
    'shop.detail.orders.client': 'Client',
    'shop.detail.products.empty': 'Aucun produit',
    'shop.detail.products.emptySubtitle': 'Ajoutez votre premier produit',
    'shop.detail.products.add': 'Ajouter',
    'shop.detail.viewShop': 'Voir la boutique',
    'shop.detail.themeActive': 'Thème actif',
    'shop.card.products': '{count} produits',
    'shop.order.status.pending': 'En attente',
    'shop.order.status.shipped': 'Expédiée',
    'shop.order.status.delivered': 'Livrée',
    'shop.order.status.cancelled': 'Annulée',

    // ─── Shop form ───
    'form.logo': 'Logo',
    'form.name': 'Nom de la boutique',
    'form.domain': 'Nom de domaine',
    'form.domainHint': 'maboutique',
    'form.domainHelper':
        'Votre boutique sera visible sur {domain}.{appDomain}',
    'form.whatsapp': 'Numéro WhatsApp',
    'form.whatsappHint': '77 000 00 00',
    'form.coverSection': 'Section de couverture',
    'form.heroTitle': 'Titre principal',
    'form.heroDescription': 'Description',
    'form.heroDescriptionHint': 'Ce que vous vendez, en une phrase',
    'form.coverImage': 'Image de couverture',
    'form.aboutSection': 'Section à propos',
    'form.aboutTitle': 'Titre',
    'form.aboutText': 'Texte',
    'form.aboutTextHint': 'Votre histoire, votre savoir-faire',
    'form.theme': 'Thème',
    'form.preview': 'Aperçu',
    'form.preview.apply': 'Appliquer ce thème',
    'form.payment.section': 'Options avancées',
    'form.payment.checkbox': 'Activer les options avancées',
    'form.payment.field1': 'Champ 1',
    'form.payment.field2': 'Champ 2',
    'form.payment.field3': 'Champ 3',
    'form.payment.field4': 'Champ 4',
    'form.payment.field5': 'Champ 5',
    'form.payment.hint': 'À définir',
    'form.choose': 'Choisir',
    'form.create.title': 'Créer ma boutique',
    'form.create.cta': 'Créer ma boutique',
    'form.create.success': 'Boutique créée avec succès ! 🎉',
    'form.create.failed': 'Impossible de créer la boutique',
    'form.update.title': 'Personnaliser la boutique',
    'form.update.cta': 'Enregistrer',
    'form.update.success': 'Boutique mise à jour ✅',
    'form.update.failed': 'Impossible de modifier cette boutique',
    'form.uploadFailed': "L'image n'a pas pu être envoyée",

    // ─── Locked themes ───
    'theme.locked': 'Bientôt disponible',
    'theme.comingSoon': 'Le thème {name} arrive bientôt',

    // ─── Products (seller side) ───
    'product.form.add.title': 'Ajouter un produit',
    'product.form.edit.title': 'Modifier le produit',
    'product.form.photos': 'Photos du produit',
    'product.form.addPhoto': 'Ajouter',
    'product.form.name': 'Nom du produit',
    'product.form.nameHint': 'Ex: iPhone 14 Pro Max',
    'product.form.description': 'Description',
    'product.form.descriptionHint': 'Décrivez votre produit…',
    'product.form.price': 'Prix (FCFA)',
    'product.form.category': 'Catégorie',
    'product.form.categoryHint': 'Choisir une catégorie',
    'product.form.condition': 'État du produit',
    'product.form.priceLabel': 'Prix',
    'product.form.negotiable': 'Négociable',
    'product.form.fixedPrice': 'Prix fixe',
    'product.form.publish': 'Publier le produit',
    'product.form.needPhoto': 'Veuillez ajouter au moins une photo',
    'product.form.uploadFailed': 'Les photos n\'ont pas pu être envoyées',
    'product.form.published': 'Produit publié avec succès !',
    'product.form.updated': 'Produit mis à jour',
    'product.form.publishFailed': 'Impossible de publier le produit',
    'product.form.required': 'Ce champ est requis',
    'product.menu.edit': 'Modifier',
    'product.menu.delete': 'Supprimer',
    'product.delete.title': 'Supprimer le produit ?',
    'product.delete.body': '« {name} » sera retiré de votre boutique.',
    'product.delete.done': 'Produit supprimé',
    'product.delete.failed': 'Suppression impossible',

    // ─── Notifications ───
    'notifications.title': 'Notifications',
    'notifications.empty': 'Aucune notification pour le moment',
    'notifications.markAllRead': 'Tout marquer comme lu',
    'notifications.unreadBadge': '{count} non lue(s)',

    // ─── Language ───
    'language.title': 'Langue',
    'language.subtitle':
        'Choisissez la langue de l\'application. Les produits, boutiques et profils restent dans la langue de leur auteur.',
    'language.applied': 'Langue appliquée : {language}',
    'language.current': 'Langue actuelle',

    // ─── Help ───
    'help.title': 'Aide & Support',
    'privacy.title': 'Confidentialité',
    'privacy.subtitle': 'Vos données et leur suppression',
    'privacy.openWeb': 'Lire la politique complète',
    'privacy.support': 'Support',
    'delete.title': 'Supprimer mon compte',
    'delete.warningTitle': 'Action définitive',
    'delete.warningBody':
        'La suppression de votre compte est définitive et irréversible. Vos données ne pourront pas être récupérées. Si vous changez d\u2019avis, vous devrez créer un nouveau compte.',
    'delete.whatTitle': 'Ce qui sera supprimé',
    'delete.items.account': 'Votre compte et vos identifiants de connexion',
    'delete.items.personal':
        'Votre adresse e-mail, votre nom d\u2019utilisateur et vos informations personnelles',
    'delete.items.shops':
        'Vos boutiques, ainsi que leurs produits, logos et bannières',
    'delete.items.orders': 'Les commandes reçues et celles que vous avez passées',
    'delete.items.reviews': 'Vos avis laissés sur les autres boutiques',
    'delete.items.favorites': 'Vos favoris et le contenu de votre panier',
    'delete.items.activity': 'Votre historique d\u2019activité',
    'delete.confirmPassword': 'Confirmez avec votre mot de passe',
    'delete.passwordHint': 'Votre mot de passe',
    'delete.account': 'Compte : {email}',
    'delete.cta': 'Supprimer définitivement mon compte',
    'delete.deleting': 'Suppression en cours…',
    'delete.done': 'Votre compte a été supprimé',
    'delete.failed': 'Suppression impossible',
    'signup.termsPrefix': 'J\u2019accepte la ',
    'signup.termsLink': 'politique de confidentialité',
    'signup.termsSuffix': ' et la suppression de mon compte',
    'signup.termsRequired': 'Vous devez accepter la politique de confidentialité',
    'help.subtitle':
        'Une question sur une commande, un produit ou votre boutique ? Écrivez-nous sur WhatsApp, nous répondons rapidement.',
    'help.cta': 'Écrire sur WhatsApp',
    'help.hours': 'Du lundi au samedi, de 9h à 18h.',

    // ─── About ───
    'about.title': 'À propos',
    'about.tagline': 'La marketplace des boutiques indépendantes',
    'about.intro':
        'EZ Shop donne à chaque vendeur son propre espace : une boutique à son nom, son adresse et son thème, puis la liberté de vendre sur WhatsApp, là où ses clients se trouvent déjà.',
    'about.features.title': 'Ce que vous pouvez faire',
    'about.feature.shop': 'Créer une boutique et choisir son thème',
    'about.feature.domain': 'Publier votre vitrine sur votre propre adresse',
    'about.feature.products': 'Ajouter vos produits avec vos photos',
    'about.feature.negotiate': 'Fixer un prix négociable ou un prix fixe',
    'about.feature.whatsapp': 'Commander ou vendre directement sur WhatsApp',
    'about.feature.rate': 'Noter les boutiques et consulter les avis',
    'about.version': 'Version {version}',
    'about.rights': '© {year} EZ Shop. Tous droits réservés.',

    // ─── Coming soon ───
    'soon.title': 'Bientôt disponible',
    'soon.back': 'Retour',
    'soon.boostMessage':
        'Cette fonctionnalité n\'est pas encore disponible. Vous pourrez bientôt mettre vos produits en avant et suivre leur visibilité depuis votre boutique.',

    // ─── Cropper ───
    'crop.title': 'Recadrer',
    'crop.logo': 'Logo de la boutique',
    'crop.cover': 'Image de couverture',
    'crop.profile': 'Photo de profil',
    'crop.validate': 'Valider',
    'crop.failed': 'Recadrage impossible',

    // ─── WebView ───
    'webview.loading': 'Chargement de la boutique…',
    'webview.error': 'Impossible de charger la boutique.',
    'webview.retry': 'Réessayer',

    // ─── Auth (validation) ───
    'auth.login.emailHint': 'votre@email.com',
    'auth.login.emailRequired': 'E-mail requis',
    'auth.login.passwordRequired': 'Mot de passe requis',
    'auth.login.passwordMin': 'Minimum 6 caractères',
    'auth.login.error': 'Erreur de connexion',
    'auth.login.google': 'Continuer avec Google',
    'auth.login.haveAccount': 'Déjà un compte ?',
    'auth.signup.nameHint': 'Jean Dupont',
    'auth.signup.nameRequired': 'Nom requis',
    'auth.signup.emailRequired': 'E-mail requis',
    'auth.signup.passwordRequired': 'Mot de passe requis',
    'auth.signup.confirmRequired': 'Confirmation requise',
    'auth.signup.mismatch': 'Les mots de passe ne correspondent pas',
    'auth.forgot.success': 'E-mail envoyé !',

    // ─── Shop list ───
    'shop.list.empty': 'Aucune boutique',
    'shop.list.emptySubtitle': 'Vous n\'avez pas encore de boutique. Créez la première pour vendre vos produits.',
    'shop.list.createFirst': 'Créer ma première boutique',

    // ─── Shop webview ───
    'webview.reload': 'Recharger',
    'webview.openBrowser': 'Ouvrir dans le navigateur',
    'webview.unreachable': 'Boutique injoignable',
    'webview.unreachableBody': 'Cette boutique ne répond pas pour le moment.',
    'webview.loadFailed': 'Impossible de charger la boutique.',
    'webview.noDomain': 'Cette boutique n\'a pas encore de nom de domaine.',
    'webview.cannotDisplay': 'Impossible d\'afficher {url}',

    // ─── Theme preview ───
    'preview.apply': 'Utiliser ce thème',
    'preview.shopName': 'Votre Boutique',
    'preview.description': 'Description de la boutique',
    'preview.about': 'À propos',
    'preview.discover': 'Découvrir la collection',
    'preview.aboutOf': 'À propos de {name}',
    'preview.welcome': 'Bienvenue chez {name}',
    'preview.byline': 'Boutique · @{slug}',
    'preview.footer': '{name} · Boutique sur EZ Shop',
    'preview.available': '{count} disponibles',
    'preview.fresh': '{count} neufs',
    'preview.soldOut': 'Épuisé',
    'preview.products': 'produits',
    'preview.availableCount': 'disponibles',
    'preview.freshCount': 'neufs',
    'preview.usedShort': 'Occas.',
  };

  // ═══════════════════════════════════
  //  ENGLISH
  // ═══════════════════════════════════

  static const Map<String, String> _en = {
    // ─── Common ───
    'common.cancel': 'Cancel',
    'common.save': 'Save',
    'common.retry': 'Try again',
    'common.back': 'Back',
    'common.loading': 'Loading…',
    'common.delete': 'Delete',
    'common.edit': 'Edit',

    // ─── Auth ───
    'auth.login.title': 'Sign in',
    'auth.login.subtitle': 'Sign in to buy and sell',
    'auth.login.email': 'Email address',
    'auth.login.password': 'Password',
    'auth.login.cta': 'Sign in',
    'auth.login.forgot': 'Forgot your password?',
    'auth.login.noAccount': 'No account yet?',
    'auth.login.createAccount': 'Sign up',
    'auth.signup.title': 'Create an account',
    'auth.signup.subtitle': 'Join our marketplace and start buying and selling',
    'auth.signup.name': 'Full name',
    'auth.signup.confirm': 'Confirm password',
    'auth.signup.cta': 'Create my account',
    'auth.signup.haveAccount': 'Already have an account?',
    'auth.forgot.title': 'Forgot password',
    'auth.forgot.subtitle':
        'Enter your email and we will send you a reset link.',
    'auth.forgot.cta': 'Send the link',
    'auth.forgot.sent': 'If an account exists, an email has just been sent.',
    'auth.forgot.backToLogin': 'Back to sign in',

    // ─── Navigation ───
    'nav.home': 'Home',
    'nav.search': 'Search',
    'nav.shops': 'Shops',
    'nav.favorites': 'Favorites',
    'nav.profile': 'Profile',

    // ─── Home ───
    'home.guest': 'Guest',
    'home.banner.tag': '🏪 EZ Shop',
    'home.banner.title': 'Create your own shop',
    'home.banner.subtitle': 'List your products and sell online',
    'home.banner.cta': 'Get started →',
    'home.filter.all': 'All',
    'home.filter.neuf': 'New',
    'home.filter.occasion': 'Used',
    'home.products': 'Products',
    'home.products.empty': 'No products',
    'home.shops.popular': 'Popular shops',

    // ─── Search ───
    'search.hint': 'Search…',
    'search.empty.title': 'No results found',
    'search.empty.subtitle': 'Try other keywords',

    // ─── Favorites ───
    'favorites.title': 'My favorites',
    'favorites.empty.title': 'No favorites yet',
    'favorites.empty.subtitle': 'Tap ♡ to save a product',

    // ─── Profile ───
    'profile.title': 'My profile',
    'profile.guest': 'Guest',
    'profile.settings': 'Settings',
    'profile.menu.shops': 'My shops',
    'profile.menu.orders': 'My orders',
    'profile.menu.favorites': 'My favorites',
    'profile.menu.validation': 'Validation',
    'profile.menu.language': 'Language',
    'profile.menu.notifications': 'Notifications',
    'profile.menu.help': 'Help & support',
    'profile.menu.about': 'About',
    'profile.logout': 'Sign out',
    'profile.edit.title': 'Edit profile',
    'profile.edit.name': 'Name',
    'profile.edit.nameHint': 'Your name',
    'profile.edit.phone': 'Phone',
    'profile.edit.phoneHint': '+1 555 00 00 00',
    'profile.edit.address': 'Address',
    'profile.edit.addressHint': 'Your address',
    'profile.edit.saved': 'Profile updated',
    'profile.edit.failed': 'Could not save',
    'profile.orders.title': 'Orders received',
    'profile.orders.empty': 'No orders received yet',
    'profile.avatar.updated': 'Profile photo updated',
    'profile.avatar.failed': 'Photo not saved',
    'profile.avatar.cropTitle': 'Profile photo',

    // ─── Product ───
    'product.tag.neuf': 'New',
    'product.tag.occasion': 'Used',
    'product.tag.negotiable': 'Negotiable',
    'product.tag.fixedPrice': 'Fixed price',
    'product.description': 'Description',
    'product.soldBy': 'Sold by',
    'product.rate': '• Rate',
    'product.noReviews': 'No reviews yet',
    'product.negotiableHint': 'Negotiable price: make your offer on WhatsApp.',
    'product.orderWhatsapp': 'Order on WhatsApp',
    'product.unknownShop': 'Unknown shop',
    'product.noWhatsapp':
        'WhatsApp unavailable: this shop has not set a phone number.',
    'product.orderAlreadyRecorded': 'Already ordered today',
    'product.orderFailed': 'Order not recorded',
    'product.whatsappMessage':
        'Hello, I am interested in your product “{name}” at {price}, found on EZ Shop.',

    // ─── Shop rating ───
    'rating.new': 'Rate the shop',
    'rating.edit': 'Edit your rating',
    'rating.send': 'Send my rating',
    'rating.update': 'Update',
    'rating.none': 'No reviews yet',
    'rating.summary': '{average} / 5 • {count} reviews',
    'rating.hint':
        'One rating per shop: you can change it at any time.',
    'rating.thanks': 'Thanks for your rating!',
    'rating.updated': 'Your rating has been updated',
    'rating.failed': 'Could not save your rating',

    // ─── Shops ───
    'shop.list.title': 'My shops',
    'shop.list.new': 'New shop',
    'shop.detail.personalise': 'Customise the shop',
    'shop.detail.stats.products': 'Products',
    'shop.detail.stats.orders': 'Orders',
    'shop.detail.stats.rating': 'Rating',
    'shop.detail.boost.title': 'Boost your sales',
    'shop.detail.boost.subtitle':
        'Feature your products and attract more customers.',
    'shop.detail.orders.title': 'Orders received',
    'shop.detail.danger.title': 'Danger zone',
    'shop.detail.danger.delete': 'Delete this shop',
    'shop.detail.danger.done': 'Shop deleted',
    'shop.detail.danger.failed': 'Could not delete the shop',
    'shop.detail.delete.title': 'Delete the shop?',
    'shop.detail.delete.body':
        '"{name}" will be deleted, along with everything that depends on it:',
    'shop.detail.delete.unknownCounts':
        'Could not count what will be deleted. Try again before confirming.',
    'shop.detail.delete.products': '{count} product(s)',
    'shop.detail.delete.orders': '{count} order(s) received',
    'shop.detail.delete.ratings': '{count} review(s)',
    'shop.detail.delete.confirmLabel':
        'Type "{name}" to confirm. This cannot be undone.',
    'shop.detail.delete.confirm': 'Delete permanently',
    'shop.detail.orders.empty': 'No orders yet.',
    'shop.detail.orders.client': 'Customer',
    'shop.detail.products.empty': 'No products',
    'shop.detail.products.emptySubtitle': 'Add your first product',
    'shop.detail.products.add': 'Add',
    'shop.detail.viewShop': 'View the shop',
    'shop.detail.themeActive': 'Active theme',
    'shop.card.products': '{count} products',
    'shop.order.status.pending': 'Pending',
    'shop.order.status.shipped': 'Shipped',
    'shop.order.status.delivered': 'Delivered',
    'shop.order.status.cancelled': 'Cancelled',

    // ─── Shop form ───
    'form.logo': 'Logo',
    'form.name': 'Shop name',
    'form.domain': 'Domain name',
    'form.domainHint': 'myshop',
    'form.domainHelper': 'Your shop will be visible on {domain}.{appDomain}',
    'form.whatsapp': 'WhatsApp number',
    'form.whatsappHint': '77 000 00 00',
    'form.coverSection': 'Cover section',
    'form.heroTitle': 'Main title',
    'form.heroDescription': 'Description',
    'form.heroDescriptionHint': 'What you sell, in one sentence',
    'form.coverImage': 'Cover image',
    'form.aboutSection': 'About section',
    'form.aboutTitle': 'Title',
    'form.aboutText': 'Text',
    'form.aboutTextHint': 'Your story, your craft',
    'form.theme': 'Theme',
    'form.preview': 'Preview',
    'form.preview.apply': 'Apply this theme',
    'form.payment.section': 'Advanced options',
    'form.payment.checkbox': 'Enable advanced options',
    'form.payment.field1': 'Field 1',
    'form.payment.field2': 'Field 2',
    'form.payment.field3': 'Field 3',
    'form.payment.field4': 'Field 4',
    'form.payment.field5': 'Field 5',
    'form.payment.hint': 'To be defined',
    'form.choose': 'Choose',
    'form.create.title': 'Create my shop',
    'form.create.cta': 'Create my shop',
    'form.create.success': 'Shop created! 🎉',
    'form.create.failed': 'Could not create the shop',
    'form.update.title': 'Customise the shop',
    'form.update.cta': 'Save',
    'form.update.success': 'Shop updated ✅',
    'form.update.failed': 'Could not update this shop',
    'form.uploadFailed': 'The image could not be uploaded',

    // ─── Locked themes ───
    'theme.locked': 'Coming soon',
    'theme.comingSoon': '{name} is coming soon',

    // ─── Products (seller side) ───
    'product.form.add.title': 'Add a product',
    'product.form.edit.title': 'Edit the product',
    'product.form.photos': 'Product photos',
    'product.form.addPhoto': 'Add',
    'product.form.name': 'Product name',
    'product.form.nameHint': 'e.g. iPhone 14 Pro Max',
    'product.form.description': 'Description',
    'product.form.descriptionHint': 'Describe your product…',
    'product.form.price': 'Price (FCFA)',
    'product.form.category': 'Category',
    'product.form.categoryHint': 'Choose a category',
    'product.form.condition': 'Condition',
    'product.form.priceLabel': 'Price',
    'product.form.negotiable': 'Negotiable',
    'product.form.fixedPrice': 'Fixed price',
    'product.form.publish': 'Publish the product',
    'product.form.needPhoto': 'Please add at least one photo',
    'product.form.uploadFailed': 'The photos could not be uploaded',
    'product.form.published': 'Product published!',
    'product.form.updated': 'Product updated',
    'product.form.publishFailed': 'Could not publish the product',
    'product.form.required': 'This field is required',
    'product.menu.edit': 'Edit',
    'product.menu.delete': 'Delete',
    'product.delete.title': 'Delete the product?',
    'product.delete.body': '“{name}” will be removed from your shop.',
    'product.delete.done': 'Product deleted',
    'product.delete.failed': 'Could not delete',

    // ─── Notifications ───
    'notifications.title': 'Notifications',
    'notifications.empty': 'No notifications yet',
    'notifications.markAllRead': 'Mark all as read',
    'notifications.unreadBadge': '{count} unread',

    // ─── Language ───
    'language.title': 'Language',
    'language.subtitle':
        'Choose the language of the app. Products, shops and profiles stay in the language of their author.',
    'language.applied': 'Language set to {language}',
    'language.current': 'Current language',

    // ─── Help ───
    'help.title': 'Help & support',
    'privacy.title': 'Privacy',
    'privacy.subtitle': 'Your data and its deletion',
    'privacy.openWeb': 'Read the full policy',
    'privacy.support': 'Support',
    'delete.title': 'Delete my account',
    'delete.warningTitle': 'Permanent action',
    'delete.warningBody':
        'Deleting your account is permanent and irreversible. Your data cannot be recovered. If you change your mind, you will have to create a new account.',
    'delete.whatTitle': 'What will be deleted',
    'delete.items.account': 'Your account and login credentials',
    'delete.items.personal':
        'Your email address, username and personal information',
    'delete.items.shops':
        'Your shops, along with their products, logos and banners',
    'delete.items.orders': 'The orders you received and the ones you placed',
    'delete.items.reviews': 'The reviews you left on other shops',
    'delete.items.favorites': 'Your favourites and your cart',
    'delete.items.activity': 'Your activity history',
    'delete.confirmPassword': 'Confirm with your password',
    'delete.passwordHint': 'Your password',
    'delete.account': 'Account: {email}',
    'delete.cta': 'Delete my account permanently',
    'delete.deleting': 'Deleting…',
    'delete.done': 'Your account has been deleted',
    'delete.failed': 'Could not delete the account',
    'signup.termsPrefix': 'I accept the ',
    'signup.termsLink': 'privacy policy',
    'signup.termsSuffix': ' and the account deletion',
    'signup.termsRequired': 'You must accept the privacy policy',
    'help.subtitle':
        'A question about an order, a product or your shop? Message us on WhatsApp, we answer quickly.',
    'help.cta': 'Message us on WhatsApp',
    'help.hours': 'Monday to Saturday, 9am to 6pm.',

    // ─── About ───
    'about.title': 'About',
    'about.tagline': 'The marketplace for independent shops',
    'about.intro':
        'EZ Shop gives every seller their own space: a shop with their name, their address and their theme, then the freedom to sell on WhatsApp, where their customers already are.',
    'about.features.title': 'What you can do',
    'about.feature.shop': 'Create a shop and pick its theme',
    'about.feature.domain': 'Publish your storefront on your own address',
    'about.feature.products': 'Add your products with your photos',
    'about.feature.negotiate': 'Set a negotiable or a fixed price',
    'about.feature.whatsapp': 'Order or sell directly on WhatsApp',
    'about.feature.rate': 'Rate shops and read the reviews',
    'about.version': 'Version {version}',
    'about.rights': '© {year} EZ Shop. All rights reserved.',

    // ─── Coming soon ───
    'soon.title': 'Coming soon',
    'soon.back': 'Back',
    'soon.boostMessage':
        'This feature is not available yet. Soon you will be able to feature your products and track their visibility from your shop.',

    // ─── Cropper ───
    'crop.title': 'Crop',
    'crop.logo': 'Shop logo',
    'crop.cover': 'Cover image',
    'crop.profile': 'Profile photo',
    'crop.validate': 'Confirm',
    'crop.failed': 'Could not crop',

    // ─── WebView ───
    'webview.loading': 'Loading the shop…',
    'webview.error': 'Could not load the shop.',
    'webview.retry': 'Try again',

    // ─── Auth (validation) ───
    'auth.login.emailHint': 'your@email.com',
    'auth.login.emailRequired': 'Email is required',
    'auth.login.passwordRequired': 'Password is required',
    'auth.login.passwordMin': 'At least 6 characters',
    'auth.login.error': 'Sign-in failed',
    'auth.login.google': 'Continue with Google',
    'auth.login.haveAccount': 'Already have an account?',
    'auth.signup.nameHint': 'John Doe',
    'auth.signup.nameRequired': 'Name is required',
    'auth.signup.emailRequired': 'Email is required',
    'auth.signup.passwordRequired': 'Password is required',
    'auth.signup.confirmRequired': 'Confirmation is required',
    'auth.signup.mismatch': 'Passwords do not match',
    'auth.forgot.success': 'Email sent!',

    // ─── Shop list ───
    'shop.list.empty': 'No shop yet',
    'shop.list.emptySubtitle': 'You have no shop yet. Create the first one to sell your products.',
    'shop.list.createFirst': 'Create my first shop',

    // ─── Shop webview ───
    'webview.reload': 'Reload',
    'webview.openBrowser': 'Open in browser',
    'webview.unreachable': 'Shop unreachable',
    'webview.unreachableBody': 'This shop is not answering right now.',
    'webview.loadFailed': 'Could not load the shop.',
    'webview.noDomain': 'This shop has no domain name yet.',
    'webview.cannotDisplay': 'Could not display {url}',

    // ─── Theme preview ───
    'preview.apply': 'Use this theme',
    'preview.shopName': 'Your shop',
    'preview.description': 'Shop description',
    'preview.about': 'About',
    'preview.discover': 'Discover the collection',
    'preview.aboutOf': 'About {name}',
    'preview.welcome': 'Welcome to {name}',
    'preview.byline': 'Shop · @{slug}',
    'preview.footer': '{name} · Shop on EZ Shop',
    'preview.available': '{count} available',
    'preview.fresh': '{count} new',
    'preview.soldOut': 'Sold out',
    'preview.products': 'products',
    'preview.availableCount': 'available',
    'preview.freshCount': 'new',
    'preview.usedShort': 'Used',
  };
}

/// Makes the current [AppStrings] available to the whole tree.
///
/// A plain InheritedWidget rather than a package: the app has two languages and
/// a key/value catalog, which does not need code generation, and adding a
/// language stays a data-only change.
class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final AppStrings strings;

  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    return scope?.strings ?? const AppStrings(AppLanguage.fr);
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) =>
      oldWidget.strings.language != strings.language;
}

/// Shorthand: `context.l10n.t('profile.title')`.
extension AppLocalizations on BuildContext {
  AppStrings get l10n => AppLocaleScope.of(this);
}