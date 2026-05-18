import 'dart:convert';
import 'package:flutter/material.dart';

/// A helper widget that displays an image from either a network URL
/// or a base64 data URI string. Falls back to a placeholder on error.
class SmartNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const SmartNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Handle base64 data URIs
    if (imageUrl.startsWith('data:')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } catch (_) {
        return _buildFallback();
      }
    }

    // Handle regular network URLs
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.white.withValues(alpha: 0.05),
          child: const Icon(Icons.landscape, color: Colors.white24, size: 40),
        );
  }
}

/// Returns an [ImageProvider] that handles both network URLs and base64 data URIs.
ImageProvider? smartImageProvider(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('data:')) {
    try {
      return MemoryImage(base64Decode(url.split(',').last));
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(url);
}
