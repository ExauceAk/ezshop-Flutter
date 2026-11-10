import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_strings.dart';
import '../widgets/image_crop_screen.dart';
import 'app_toast.dart';

/// Maximum allowed image file size (50 MB).
const int kMaxImageSizeBytes = 50 * 1024 * 1024;

/// Checks that [file] does not exceed [kMaxImageSizeBytes].
/// Shows an error toast and returns false if the file is too large.
Future<bool> validateImageFileSize(BuildContext context, File file) async {
  final size = await file.length();
  if (size > kMaxImageSizeBytes) {
    if (context.mounted) {
      AppToast.error(context.l10n.t('form.imageTooLarge'), context: context);
    }
    return false;
  }
  return true;
}

/// Picks an image from the gallery and lets the seller frame it before it is
/// used.
///
/// Every avatar, logo and banner in the app goes through here, so an image
/// always lands in the shape its slot expects: a round avatar or a square logo
/// stays centred instead of being cropped by the layout at display time, and a
/// banner is not silently stretched.
///
/// @param aspectRatio width / height the crop rectangle is locked to.
/// @returns the cropped file, or null if the user cancelled or backed out of
/// the cropper.
Future<File?> pickAndCropImage(
  BuildContext context, {
  required double aspectRatio,
  String title = 'Recadrer',
  bool circle = false,
}) async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    // Downscaled before cropping: a 12 MP photo only makes the cropper lag on
    // a mid-range phone, and the result is displayed at a few hundred pixels.
    maxWidth: 2400,
    maxHeight: 2400,
  );
  if (picked == null) return null;

  final pickedFile = File(picked.path);
  if (!context.mounted) return null;
  if (!await validateImageFileSize(context, pickedFile)) return null;

  final bytes = await pickedFile.readAsBytes();
  if (!context.mounted) return null;

  return Navigator.of(context).push<File>(
    MaterialPageRoute(
      builder: (_) => ImageCropScreen(
        imageBytes: bytes,
        aspectRatio: aspectRatio,
        title: title,
        circle: circle,
      ),
    ),
  );
}

/// Square crop, used by anything shown in a circle.
///
/// Framed as a circle rather than a square so the photo is composed for the
/// shape it will be displayed in.
Future<File?> pickAndCropSquare(BuildContext context, {String title = 'Recadrer'}) {
  return pickAndCropImage(context, aspectRatio: 1, title: title, circle: true);
}