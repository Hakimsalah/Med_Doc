import 'package:flutter/material.dart';

class SafeAssetImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SafeAssetImage(
    this.image, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
