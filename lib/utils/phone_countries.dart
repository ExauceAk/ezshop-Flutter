import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Country dial-code entry with national phone number length bounds (E.164).
class PhoneCountry {
  const PhoneCountry({
    required this.isoCode,
    required this.dialCode,
    required this.nameFr,
    required this.nameEn,
    this.minLength = 8,
    this.maxLength = 10,
  });

  final String isoCode;
  final String dialCode;
  final String nameFr;
  final String nameEn;
  final int minLength;
  final int maxLength;

  String localizedName(AppLanguage language) =>
      language == AppLanguage.en ? nameEn : nameFr;

  String get expectedDigitsLabel =>
      minLength == maxLength ? '$minLength' : '$minLength-$maxLength';
}

/// Complete list of international country calling codes and national phone
/// length rules. Francophone West/Central/North African and European countries
/// are placed at the top for quick access, followed by all other countries
/// sorted alphabetically.
const List<PhoneCountry> kPhoneCountries = [
  // Priority countries
  PhoneCountry(isoCode: 'SN', dialCode: '221', nameFr: 'Sénégal', nameEn: 'Senegal', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'CI', dialCode: '225', nameFr: 'Côte d’Ivoire', nameEn: 'Ivory Coast', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'ML', dialCode: '223', nameFr: 'Mali', nameEn: 'Mali', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'BF', dialCode: '226', nameFr: 'Burkina Faso', nameEn: 'Burkina Faso', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'BJ', dialCode: '229', nameFr: 'Bénin', nameEn: 'Benin', minLength: 8, maxLength: 10),
  PhoneCountry(isoCode: 'TG', dialCode: '228', nameFr: 'Togo', nameEn: 'Togo', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'GN', dialCode: '224', nameFr: 'Guinée', nameEn: 'Guinea', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'NE', dialCode: '227', nameFr: 'Niger', nameEn: 'Niger', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'CM', dialCode: '237', nameFr: 'Cameroun', nameEn: 'Cameroon', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'GA', dialCode: '241', nameFr: 'Gabon', nameEn: 'Gabon', minLength: 7, maxLength: 8),
  PhoneCountry(isoCode: 'CG', dialCode: '242', nameFr: 'Congo-Brazzaville', nameEn: 'Republic of the Congo', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'CD', dialCode: '243', nameFr: 'RD Congo', nameEn: 'DR Congo', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'MA', dialCode: '212', nameFr: 'Maroc', nameEn: 'Morocco', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'DZ', dialCode: '213', nameFr: 'Algérie', nameEn: 'Algeria', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'TN', dialCode: '216', nameFr: 'Tunisie', nameEn: 'Tunisia', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'FR', dialCode: '33', nameFr: 'France', nameEn: 'France', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'BE', dialCode: '32', nameFr: 'Belgique', nameEn: 'Belgium', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'CH', dialCode: '41', nameFr: 'Suisse', nameEn: 'Switzerland', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'CA', dialCode: '1', nameFr: 'Canada', nameEn: 'Canada', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'US', dialCode: '1', nameFr: 'États-Unis', nameEn: 'United States', minLength: 10, maxLength: 10),

  // All other countries
  PhoneCountry(isoCode: 'AF', dialCode: '93', nameFr: 'Afghanistan', nameEn: 'Afghanistan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'ZA', dialCode: '27', nameFr: 'Afrique du Sud', nameEn: 'South Africa', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'AL', dialCode: '355', nameFr: 'Albanie', nameEn: 'Albania', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'DE', dialCode: '49', nameFr: 'Allemagne', nameEn: 'Germany', minLength: 9, maxLength: 11),
  PhoneCountry(isoCode: 'AD', dialCode: '376', nameFr: 'Andorre', nameEn: 'Andorra', minLength: 6, maxLength: 9),
  PhoneCountry(isoCode: 'AO', dialCode: '244', nameFr: 'Angola', nameEn: 'Angola', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'SA', dialCode: '966', nameFr: 'Arabie saoudite', nameEn: 'Saudi Arabia', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'AR', dialCode: '54', nameFr: 'Argentine', nameEn: 'Argentina', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'AM', dialCode: '374', nameFr: 'Arménie', nameEn: 'Armenia', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'AU', dialCode: '61', nameFr: 'Australie', nameEn: 'Australia', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'AT', dialCode: '43', nameFr: 'Autriche', nameEn: 'Austria', minLength: 9, maxLength: 11),
  PhoneCountry(isoCode: 'AZ', dialCode: '994', nameFr: 'Azerbaïdjan', nameEn: 'Azerbaijan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'BS', dialCode: '1242', nameFr: 'Bahamas', nameEn: 'Bahamas', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'BH', dialCode: '973', nameFr: 'Bahreïn', nameEn: 'Bahrain', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'BD', dialCode: '880', nameFr: 'Bangladesh', nameEn: 'Bangladesh', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'BB', dialCode: '1246', nameFr: 'Barbade', nameEn: 'Barbados', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'BZ', dialCode: '501', nameFr: 'Belize', nameEn: 'Belize', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'BT', dialCode: '975', nameFr: 'Bhoutan', nameEn: 'Bhutan', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'BY', dialCode: '375', nameFr: 'Biélorussie', nameEn: 'Belarus', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'MM', dialCode: '95', nameFr: 'Birmanie', nameEn: 'Myanmar', minLength: 8, maxLength: 10),
  PhoneCountry(isoCode: 'BO', dialCode: '591', nameFr: 'Bolivie', nameEn: 'Bolivia', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'BA', dialCode: '387', nameFr: 'Bosnie-Herzégovine', nameEn: 'Bosnia and Herzegovina', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'BW', dialCode: '267', nameFr: 'Botswana', nameEn: 'Botswana', minLength: 7, maxLength: 8),
  PhoneCountry(isoCode: 'BR', dialCode: '55', nameFr: 'Brésil', nameEn: 'Brazil', minLength: 10, maxLength: 11),
  PhoneCountry(isoCode: 'BN', dialCode: '673', nameFr: 'Brunei', nameEn: 'Brunei', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'BG', dialCode: '359', nameFr: 'Bulgarie', nameEn: 'Bulgaria', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'BI', dialCode: '257', nameFr: 'Burundi', nameEn: 'Burundi', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'KH', dialCode: '855', nameFr: 'Cambodge', nameEn: 'Cambodia', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'CV', dialCode: '238', nameFr: 'Cap-Vert', nameEn: 'Cape Verde', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'CF', dialCode: '236', nameFr: 'Centrafrique', nameEn: 'Central African Republic', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'CL', dialCode: '56', nameFr: 'Chili', nameEn: 'Chile', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'CN', dialCode: '86', nameFr: 'Chine', nameEn: 'China', minLength: 11, maxLength: 11),
  PhoneCountry(isoCode: 'CY', dialCode: '357', nameFr: 'Chypre', nameEn: 'Cyprus', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'CO', dialCode: '57', nameFr: 'Colombie', nameEn: 'Colombia', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'KM', dialCode: '269', nameFr: 'Comores', nameEn: 'Comoros', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'KR', dialCode: '82', nameFr: 'Corée du Sud', nameEn: 'South Korea', minLength: 9, maxLength: 10),
  PhoneCountry(isoCode: 'KP', dialCode: '850', nameFr: 'Corée du Nord', nameEn: 'North Korea', minLength: 8, maxLength: 10),
  PhoneCountry(isoCode: 'CR', dialCode: '506', nameFr: 'Costa Rica', nameEn: 'Costa Rica', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'HR', dialCode: '385', nameFr: 'Croatie', nameEn: 'Croatia', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'CU', dialCode: '53', nameFr: 'Cuba', nameEn: 'Cuba', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'DK', dialCode: '45', nameFr: 'Danemark', nameEn: 'Denmark', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'DJ', dialCode: '253', nameFr: 'Djibouti', nameEn: 'Djibouti', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'DO', dialCode: '1809', nameFr: 'République dominicaine', nameEn: 'Dominican Republic', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'EG', dialCode: '20', nameFr: 'Égypte', nameEn: 'Egypt', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'AE', dialCode: '971', nameFr: 'Émirats arabes unis', nameEn: 'United Arab Emirates', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'EC', dialCode: '593', nameFr: 'Équateur', nameEn: 'Ecuador', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'ER', dialCode: '291', nameFr: 'Érythrée', nameEn: 'Eritrea', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'ES', dialCode: '34', nameFr: 'Espagne', nameEn: 'Spain', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'EE', dialCode: '372', nameFr: 'Estonie', nameEn: 'Estonia', minLength: 7, maxLength: 8),
  PhoneCountry(isoCode: 'SZ', dialCode: '268', nameFr: 'Eswatini', nameEn: 'Eswatini', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'ET', dialCode: '251', nameFr: 'Éthiopie', nameEn: 'Ethiopia', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'FJ', dialCode: '679', nameFr: 'Fidji', nameEn: 'Fiji', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'FI', dialCode: '358', nameFr: 'Finlande', nameEn: 'Finland', minLength: 8, maxLength: 10),
  PhoneCountry(isoCode: 'GM', dialCode: '220', nameFr: 'Gambie', nameEn: 'Gambia', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'GE', dialCode: '995', nameFr: 'Géorgie', nameEn: 'Georgia', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'GH', dialCode: '233', nameFr: 'Ghana', nameEn: 'Ghana', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'GR', dialCode: '30', nameFr: 'Grèce', nameEn: 'Greece', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'GT', dialCode: '502', nameFr: 'Guatemala', nameEn: 'Guatemala', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'GW', dialCode: '245', nameFr: 'Guinée-Bissau', nameEn: 'Guinea-Bissau', minLength: 7, maxLength: 9),
  PhoneCountry(isoCode: 'GQ', dialCode: '240', nameFr: 'Guinée équatoriale', nameEn: 'Equatorial Guinea', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'GY', dialCode: '592', nameFr: 'Guyana', nameEn: 'Guyana', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'HT', dialCode: '509', nameFr: 'Haïti', nameEn: 'Haiti', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'HN', dialCode: '504', nameFr: 'Honduras', nameEn: 'Honduras', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'HK', dialCode: '852', nameFr: 'Hong Kong', nameEn: 'Hong Kong', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'HU', dialCode: '36', nameFr: 'Hongrie', nameEn: 'Hungary', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'IN', dialCode: '91', nameFr: 'Inde', nameEn: 'India', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'ID', dialCode: '62', nameFr: 'Indonésie', nameEn: 'Indonesia', minLength: 9, maxLength: 12),
  PhoneCountry(isoCode: 'IQ', dialCode: '964', nameFr: 'Irak', nameEn: 'Iraq', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'IR', dialCode: '98', nameFr: 'Iran', nameEn: 'Iran', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'IE', dialCode: '353', nameFr: 'Irlande', nameEn: 'Ireland', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'IS', dialCode: '354', nameFr: 'Islande', nameEn: 'Iceland', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'IL', dialCode: '972', nameFr: 'Israël', nameEn: 'Israel', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'IT', dialCode: '39', nameFr: 'Italie', nameEn: 'Italy', minLength: 9, maxLength: 10),
  PhoneCountry(isoCode: 'JM', dialCode: '1876', nameFr: 'Jamaïque', nameEn: 'Jamaica', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'JP', dialCode: '81', nameFr: 'Japon', nameEn: 'Japan', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'JO', dialCode: '962', nameFr: 'Jordanie', nameEn: 'Jordan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'KZ', dialCode: '7', nameFr: 'Kazakhstan', nameEn: 'Kazakhstan', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'KE', dialCode: '254', nameFr: 'Kenya', nameEn: 'Kenya', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'KG', dialCode: '996', nameFr: 'Kirghizistan', nameEn: 'Kyrgyzstan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'KW', dialCode: '965', nameFr: 'Koweït', nameEn: 'Kuwait', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'LA', dialCode: '856', nameFr: 'Laos', nameEn: 'Laos', minLength: 8, maxLength: 10),
  PhoneCountry(isoCode: 'LS', dialCode: '266', nameFr: 'Lesotho', nameEn: 'Lesotho', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'LV', dialCode: '371', nameFr: 'Lettonie', nameEn: 'Latvia', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'LB', dialCode: '961', nameFr: 'Liban', nameEn: 'Lebanon', minLength: 7, maxLength: 8),
  PhoneCountry(isoCode: 'LR', dialCode: '231', nameFr: 'Liberia', nameEn: 'Liberia', minLength: 7, maxLength: 9),
  PhoneCountry(isoCode: 'LY', dialCode: '218', nameFr: 'Libye', nameEn: 'Libya', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'LI', dialCode: '423', nameFr: 'Liechtenstein', nameEn: 'Liechtenstein', minLength: 7, maxLength: 9),
  PhoneCountry(isoCode: 'LT', dialCode: '370', nameFr: 'Lituanie', nameEn: 'Lithuania', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'LU', dialCode: '352', nameFr: 'Luxembourg', nameEn: 'Luxembourg', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'MK', dialCode: '389', nameFr: 'Macédoine du Nord', nameEn: 'North Macedonia', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'MG', dialCode: '261', nameFr: 'Madagascar', nameEn: 'Madagascar', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'MY', dialCode: '60', nameFr: 'Malaisie', nameEn: 'Malaysia', minLength: 9, maxLength: 10),
  PhoneCountry(isoCode: 'MW', dialCode: '265', nameFr: 'Malawi', nameEn: 'Malawi', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'MV', dialCode: '960', nameFr: 'Maldives', nameEn: 'Maldives', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'MT', dialCode: '356', nameFr: 'Malte', nameEn: 'Malta', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'MR', dialCode: '222', nameFr: 'Mauritanie', nameEn: 'Mauritania', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'MU', dialCode: '230', nameFr: 'Maurice', nameEn: 'Mauritius', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'MX', dialCode: '52', nameFr: 'Mexique', nameEn: 'Mexico', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'MD', dialCode: '373', nameFr: 'Moldavie', nameEn: 'Moldova', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'MC', dialCode: '377', nameFr: 'Monaco', nameEn: 'Monaco', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'MN', dialCode: '976', nameFr: 'Mongolie', nameEn: 'Mongolia', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'ME', dialCode: '382', nameFr: 'Monténégro', nameEn: 'Montenegro', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'MZ', dialCode: '258', nameFr: 'Mozambique', nameEn: 'Mozambique', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'NA', dialCode: '264', nameFr: 'Namibie', nameEn: 'Namibia', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'NP', dialCode: '977', nameFr: 'Népal', nameEn: 'Nepal', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'NI', dialCode: '505', nameFr: 'Nicaragua', nameEn: 'Nicaragua', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'NG', dialCode: '234', nameFr: 'Nigeria', nameEn: 'Nigeria', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'NO', dialCode: '47', nameFr: 'Norvège', nameEn: 'Norway', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'NZ', dialCode: '64', nameFr: 'Nouvelle-Zélande', nameEn: 'New Zealand', minLength: 8, maxLength: 10),
  PhoneCountry(isoCode: 'OM', dialCode: '968', nameFr: 'Oman', nameEn: 'Oman', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'UG', dialCode: '256', nameFr: 'Ouganda', nameEn: 'Uganda', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'UZ', dialCode: '998', nameFr: 'Ouzbékistan', nameEn: 'Uzbekistan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'PK', dialCode: '92', nameFr: 'Pakistan', nameEn: 'Pakistan', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'PS', dialCode: '970', nameFr: 'Palestine', nameEn: 'Palestine', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'PA', dialCode: '507', nameFr: 'Panama', nameEn: 'Panama', minLength: 7, maxLength: 8),
  PhoneCountry(isoCode: 'PG', dialCode: '675', nameFr: 'Papouasie-Nouvelle-Guinée', nameEn: 'Papua New Guinea', minLength: 7, maxLength: 8),
  PhoneCountry(isoCode: 'PY', dialCode: '595', nameFr: 'Paraguay', nameEn: 'Paraguay', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'NL', dialCode: '31', nameFr: 'Pays-Bas', nameEn: 'Netherlands', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'PE', dialCode: '51', nameFr: 'Pérou', nameEn: 'Peru', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'PH', dialCode: '63', nameFr: 'Philippines', nameEn: 'Philippines', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'PL', dialCode: '48', nameFr: 'Pologne', nameEn: 'Poland', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'PT', dialCode: '351', nameFr: 'Portugal', nameEn: 'Portugal', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'QA', dialCode: '974', nameFr: 'Qatar', nameEn: 'Qatar', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'RE', dialCode: '262', nameFr: 'La Réunion', nameEn: 'Reunion', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'RO', dialCode: '40', nameFr: 'Roumanie', nameEn: 'Romania', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'GB', dialCode: '44', nameFr: 'Royaume-Uni', nameEn: 'United Kingdom', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'RU', dialCode: '7', nameFr: 'Russie', nameEn: 'Russia', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'RW', dialCode: '250', nameFr: 'Rwanda', nameEn: 'Rwanda', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'SV', dialCode: '503', nameFr: 'Salvador', nameEn: 'El Salvador', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'WS', dialCode: '685', nameFr: 'Samoa', nameEn: 'Samoa', minLength: 5, maxLength: 7),
  PhoneCountry(isoCode: 'ST', dialCode: '239', nameFr: 'Sao Tomé-et-Principe', nameEn: 'Sao Tome and Principe', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'RS', dialCode: '381', nameFr: 'Serbie', nameEn: 'Serbia', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'SC', dialCode: '248', nameFr: 'Seychelles', nameEn: 'Seychelles', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'SL', dialCode: '232', nameFr: 'Sierra Leone', nameEn: 'Sierra Leone', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'SG', dialCode: '65', nameFr: 'Singapour', nameEn: 'Singapore', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'SK', dialCode: '421', nameFr: 'Slovaquie', nameEn: 'Slovakia', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'SI', dialCode: '386', nameFr: 'Slovénie', nameEn: 'Slovenia', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'SO', dialCode: '252', nameFr: 'Somalie', nameEn: 'Somalia', minLength: 7, maxLength: 9),
  PhoneCountry(isoCode: 'SD', dialCode: '249', nameFr: 'Soudan', nameEn: 'Sudan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'SS', dialCode: '211', nameFr: 'Soudan du Sud', nameEn: 'South Sudan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'LK', dialCode: '94', nameFr: 'Sri Lanka', nameEn: 'Sri Lanka', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'SE', dialCode: '46', nameFr: 'Suède', nameEn: 'Sweden', minLength: 7, maxLength: 9),
  PhoneCountry(isoCode: 'SR', dialCode: '597', nameFr: 'Suriname', nameEn: 'Suriname', minLength: 6, maxLength: 7),
  PhoneCountry(isoCode: 'SY', dialCode: '963', nameFr: 'Syrie', nameEn: 'Syria', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'TJ', dialCode: '992', nameFr: 'Tadjikistan', nameEn: 'Tajikistan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'TW', dialCode: '886', nameFr: 'Taïwan', nameEn: 'Taiwan', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'TZ', dialCode: '255', nameFr: 'Tanzanie', nameEn: 'Tanzania', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'TD', dialCode: '235', nameFr: 'Tchad', nameEn: 'Chad', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'CZ', dialCode: '420', nameFr: 'Tchéquie', nameEn: 'Czech Republic', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'TH', dialCode: '66', nameFr: 'Thaïlande', nameEn: 'Thailand', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'TL', dialCode: '670', nameFr: 'Timor oriental', nameEn: 'Timor-Leste', minLength: 7, maxLength: 8),
  PhoneCountry(isoCode: 'TT', dialCode: '1868', nameFr: 'Trinité-et-Tobago', nameEn: 'Trinidad and Tobago', minLength: 7, maxLength: 7),
  PhoneCountry(isoCode: 'TM', dialCode: '993', nameFr: 'Turkménistan', nameEn: 'Turkmenistan', minLength: 8, maxLength: 8),
  PhoneCountry(isoCode: 'TR', dialCode: '90', nameFr: 'Turquie', nameEn: 'Turkey', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'UA', dialCode: '380', nameFr: 'Ukraine', nameEn: 'Ukraine', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'UY', dialCode: '598', nameFr: 'Uruguay', nameEn: 'Uruguay', minLength: 8, maxLength: 9),
  PhoneCountry(isoCode: 'VU', dialCode: '678', nameFr: 'Vanuatu', nameEn: 'Vanuatu', minLength: 5, maxLength: 7),
  PhoneCountry(isoCode: 'VE', dialCode: '58', nameFr: 'Venezuela', nameEn: 'Venezuela', minLength: 10, maxLength: 10),
  PhoneCountry(isoCode: 'VN', dialCode: '84', nameFr: 'Viêt Nam', nameEn: 'Vietnam', minLength: 9, maxLength: 10),
  PhoneCountry(isoCode: 'YE', dialCode: '967', nameFr: 'Yémen', nameEn: 'Yemen', minLength: 7, maxLength: 9),
  PhoneCountry(isoCode: 'ZM', dialCode: '260', nameFr: 'Zambie', nameEn: 'Zambia', minLength: 9, maxLength: 9),
  PhoneCountry(isoCode: 'ZW', dialCode: '263', nameFr: 'Zimbabwe', nameEn: 'Zimbabwe', minLength: 9, maxLength: 9),
];

/// Finds a [PhoneCountry] by its dial code, defaulting to Senegal (+221).
PhoneCountry findPhoneCountryByDialCode(String dialCode) {
  final clean = dialCode.replaceAll(RegExp(r'[^0-9]'), '');
  for (final country in kPhoneCountries) {
    if (country.dialCode == clean) return country;
  }
  return kPhoneCountries.first;
}

/// Splits a stored `wa.me/<digits>` link or phone string into `(dialCode, nationalDigits)`
/// by matching the longest country dial code first.
(String, String) splitStoredPhoneLink(String link) {
  final digits = link.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return ('221', '');

  // Sort dial codes from longest (4 digits) to shortest (1 digit).
  final sorted = List<PhoneCountry>.of(kPhoneCountries)
    ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));

  for (final country in sorted) {
    if (digits.startsWith(country.dialCode) &&
        digits.length > country.dialCode.length) {
      return (country.dialCode, digits.substring(country.dialCode.length));
    }
  }
  return ('221', digits);
}

/// Non-blocking validation check for a national phone number under [country].
/// Returns `true` when the number is empty (nothing typed yet) or matches the
/// expected digit length for [country]. Returns `false` when the user entered
/// a number whose digit count does not match the country's phone format.
bool isNationalPhoneValid(PhoneCountry country, String rawInput) {
  final trimmed = rawInput.trim();
  if (trimmed.isEmpty) return true;

  // Reject if non-phone characters were entered
  if (!RegExp(r'^[0-9\s.\-()]+$').hasMatch(trimmed)) {
    return false;
  }

  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return false;

  // Check exact national length, or length after stripping a single leading '0'
  // trunk prefix (for countries like France 06... -> 6... or UK 07... -> 7...).
  final len = digits.length;
  final matchesDirect = len >= country.minLength && len <= country.maxLength;
  final withoutLeadingZero =
      digits.startsWith('0') && digits.length > 1 ? digits.substring(1) : digits;
  final matchesWithoutTrunk = withoutLeadingZero.length >= country.minLength &&
      withoutLeadingZero.length <= country.maxLength;

  final totalE164 = country.dialCode.length + withoutLeadingZero.length;
  if (totalE164 > 15) return false;

  return matchesDirect || matchesWithoutTrunk;
}

/// Opens a searchable modal bottom sheet allowing the user to pick any country's
/// dial code.
Future<PhoneCountry?> showPhoneCountryPicker(
  BuildContext context, {
  required PhoneCountry selected,
}) {
  return showModalBottomSheet<PhoneCountry>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _PhoneCountryPickerSheet(selected: selected),
  );
}

class _PhoneCountryPickerSheet extends StatefulWidget {
  const _PhoneCountryPickerSheet({required this.selected});

  final PhoneCountry selected;

  @override
  State<_PhoneCountryPickerSheet> createState() =>
      _PhoneCountryPickerSheetState();
}

class _PhoneCountryPickerSheetState extends State<_PhoneCountryPickerSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _query.trim().toLowerCase();

    final filtered = q.isEmpty
        ? kPhoneCountries
        : kPhoneCountries.where((c) {
            return c.nameFr.toLowerCase().contains(q) ||
                c.nameEn.toLowerCase().contains(q) ||
                c.isoCode.toLowerCase().contains(q) ||
                c.dialCode.contains(q.replaceAll('+', ''));
          }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.t('form.country.title'),
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _search,
                maxLength: 40,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: l10n.t('form.country.search'),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.textHint,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          l10n.t('form.country.empty'),
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AppTheme.divider,
                        ),
                        itemBuilder: (context, index) {
                          final country = filtered[index];
                          final isSelected =
                              country.dialCode == widget.selected.dialCode &&
                                  country.isoCode == widget.selected.isoCode;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            leading: Container(
                              width: 40,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withValues(alpha: 0.12)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.border,
                                ),
                              ),
                              child: Text(
                                country.isoCode,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            title: Text(
                              country.localizedName(l10n.language),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            trailing: Text(
                              '+${country.dialCode}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                            onTap: () => Navigator.pop(context, country),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
