import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/network/api_client.dart';
import 'package:gircik/data/models/clothing_item.dart';

class ClothingRepository {
  final ApiClient _apiClient;

  ClothingRepository(this._apiClient);

  Future<List<ClothingItem>> getClothingItems() async {
    try {
      final response = await _apiClient.client.get('/clothing/');
      final data = response.data as List;
      return data.map((item) => ClothingItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Kıyafetler getirilemedi: \${_handleError(e)}');
    }
  }

  Future<ClothingItem> createClothingItem(ClothingItem item) async {
    try {
      final response = await _apiClient.client.post(
        '/clothing/',
        data: item.toJson(),
      );
      return ClothingItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Kıyafet eklenemedi: ${_handleError(e)}');
    }
  }

  Future<ClothingItem> updateClothingItem(String id, ClothingItem item) async {
    try {
      final response = await _apiClient.client.put(
        '/clothing/$id',
        data: item.toJson(),
      );
      return ClothingItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Kıyafet güncellenemedi: ${_handleError(e)}');
    }
  }

  Future<void> deleteClothingItem(String id) async {
    try {
      await _apiClient.client.delete('/clothing/$id');
    } catch (e) {
      throw Exception('Kıyafet silinemedi: \${_handleError(e)}');
    }
  }

  Future<String> uploadClothingImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });
      final response = await _apiClient.client.post(
        '/clothing/upload',
        data: formData,
      );
      return response.data['url'] as String;
    } catch (e) {
      throw Exception('Fotoğraf yüklenemedi: \${_handleError(e)}');
    }
  }

  Future<Map<String, dynamic>> analyzeClothingImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });
      final response = await _apiClient.client.post(
        '/clothing/analyze',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 45), // AI process might take longer
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Kıyafet analizi başarısız: \${_handleError(e)}');
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['detail'] != null) {
        return error.response!.data['detail'].toString();
      }
      return error.message ?? 'Bilinmeyen bir hata oluştu';
    }
    return error.toString();
  }
}

final clothingRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClothingRepository(apiClient);
});
