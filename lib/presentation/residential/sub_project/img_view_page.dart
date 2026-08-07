import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewPage extends StatelessWidget {
  final String imageData;

  const ImageViewPage({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageData.startsWith('http://') || imageData.startsWith('https://');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PhotoView(
        imageProvider: isNetwork ? NetworkImage(imageData) : FileImage(File(imageData)) as ImageProvider,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3.0,
        enableRotation: false,
        loadingBuilder: (context, event) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));
        },
      ),
    );
  }
}
