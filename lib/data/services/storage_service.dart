import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Firebase Storage Service
/// Handles file uploads and downloads
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required dynamic file, // Can be File or XFile
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      // Convert XFile to File if needed
      File fileToUpload;
      if (file is XFile) {
        fileToUpload = File(file.path);
      } else if (file is File) {
        fileToUpload = file;
      } else {
        throw Exception('نوع ملف غير مدعوم');
      }
      
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(fileToUpload);

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('خطأ في رفع الملف: ${e.toString()}');
    }
  }

  /// Upload image with compression
  Future<String> uploadImage({
    required File imageFile,
    required String folder,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    final path = '$folder/$fileName';
    return await uploadFile(
      file: imageFile,
      path: path,
      onProgress: onProgress,
    );
  }

  /// Pick and upload user avatar
  Future<String?> pickAndUploadAvatar({
    required String userId,
    Function(double)? onProgress,
  }) async {
    try {
      // Pick image from gallery
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final fileName = 'avatar_$userId.jpg';
      
      return await uploadImage(
        imageFile: file,
        folder: 'avatars',
        fileName: fileName,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception('خطأ في اختيار ورفع الصورة: ${e.toString()}');
    }
  }

  /// Pick and upload service image
  Future<String?> pickAndUploadServiceImage({
    required String serviceId,
    Function(double)? onProgress,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'service_${serviceId}_$timestamp.jpg';
      
      return await uploadImage(
        imageFile: file,
        folder: 'services',
        fileName: fileName,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception('خطأ في اختيار ورفع الصورة: ${e.toString()}');
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('خطأ في حذف الملف: ${e.toString()}');
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('خطأ في الحصول على رابط التحميل: ${e.toString()}');
    }
  }

  /// List all files in a folder
  Future<List<String>> listFiles(String folder) async {
    try {
      final ref = _storage.ref().child(folder);
      final result = await ref.listAll();
      
      final urls = await Future.wait(
        result.items.map((item) => item.getDownloadURL()),
      );
      
      return urls;
    } catch (e) {
      throw Exception('خطأ في قراءة الملفات: ${e.toString()}');
    }
  }
}
