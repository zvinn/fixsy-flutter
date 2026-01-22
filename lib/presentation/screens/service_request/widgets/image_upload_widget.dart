import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageUploadWidget extends StatefulWidget {
  final List<XFile> images;
  final Function(List<XFile>) onImagesChanged;

  const ImageUploadWidget({
    super.key,
    required this.images,
    required this.onImagesChanged,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (pickedFiles.isNotEmpty) {
        final updatedImages = [...widget.images, ...pickedFiles];
        widget.onImagesChanged(updatedImages);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصور: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo != null) {
        final updatedImages = [...widget.images, photo];
        widget.onImagesChanged(updatedImages);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التقاط الصورة: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    final updatedImages = [...widget.images];
    updatedImages.removeAt(index);
    widget.onImagesChanged(updatedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصور (اختياري)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'إضافة صور تساعد الفني في فهم المشكلة بشكل أفضل',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        
        // Image Grid
        if (widget.images.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.images[index].path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, size: 16),
                        color: Colors.white,
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        
        if (widget.images.isNotEmpty) const SizedBox(height: 12),
        
        // Upload Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('اختر من المعرض'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('التقط صورة'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
