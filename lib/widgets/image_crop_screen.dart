import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Full-screen image cropper.
///
/// Picking an image straight from the gallery keeps whatever framing the photo
/// happened to have, so a logo ends up half empty and a banner loses the shop
/// name. This screen locks the ratio the caller needs and hands back a file
/// cropped to it.
///
/// Returns the cropped file, or null when the user backs out.
class ImageCropScreen extends StatefulWidget {
  const ImageCropScreen({
    super.key,
    required this.imageBytes,
    required this.aspectRatio,
    this.title = '',
    this.circle = false,
  });

  final Uint8List imageBytes;

  /// Width / height the crop rectangle is locked to: 1 for a square logo or an
  /// avatar, wider for a banner.
  final double aspectRatio;

  /// Draws the crop area as a circle, for a photo that is only ever shown
  /// inside a round avatar: framing a square would keep the white margins a
  /// portrait shot on a light background ends up with on its sides.
  final bool circle;

  /// Screen title; empty means "use the generic word for cropping".
  final String title;

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final CropController _controller = CropController();
  bool _cropping = false;

  Future<void> _crop() async {
    if (_cropping) return;
    setState(() => _cropping = true);
    _controller.crop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _controller,
              aspectRatio: widget.aspectRatio,
              withCircleUi: widget.circle,
              onCropped: _onCropped,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cropping ? null : _crop,
                  child: Text(l10n.t('crop.validate')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Writes the cropped bytes to a temporary file so every caller keeps the
  /// one thing it already knows how to handle: a [File] to upload.
  Future<void> _onCropped(CropResult result) async {
    final l10n = context.l10n;

    switch (result) {
      case CropFailure(:final cause):
        if (mounted) {
          setState(() => _cropping = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.t('crop.failed')} : $cause'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      case CropSuccess(:final croppedImage):
        final file = await _writeTempFile(croppedImage);
        if (!mounted) return;
        Navigator.of(context).pop(file);
    }
  }

  Future<File> _writeTempFile(Uint8List bytes) async {
    final dir = Directory.systemTemp;
    final file = File(
      '${dir.path}/ez-crop-${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}