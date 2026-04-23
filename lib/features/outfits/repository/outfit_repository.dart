import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/network/api_client.dart';
import 'package:gircik/data/models/outfit_item.dart';

class OutfitRepository {
  final ApiClient _apiClient;

  OutfitRepository(this._apiClient);

  Future<List<OutfitItem>> getOutfits() async {
    try {
      final response = await _apiClient.client.get('/outfits/');
      final data = response.data as List;
      return data.map((item) => OutfitItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Kombinler getirilemedi: \${_handleError(e)}');
    }
  }

  Future<OutfitItem> createOutfit(OutfitItem outfit) async {
    try {
      final response = await _apiClient.client.post(
        '/outfits/',
        data: outfit.toJson(),
      );
      return OutfitItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Kombin oluşturulamadı: ${_handleError(e)}');
    }
  }

  Future<OutfitItem> updateOutfit(OutfitItem outfit) async {
    try {
      final response = await _apiClient.client.put(
        '/outfits/${outfit.id}',
        data: outfit.toJson(),
      );
      return OutfitItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Kombin güncellenemedi: ${_handleError(e)}');
    }
  }

  Future<void> wearOutfit(String outfitId) async {
    try {
      await _apiClient.client.post('/outfits/$outfitId/wear');
    } catch (e) {
      throw Exception('Kombin giyilemedi: ${_handleError(e)}');
    }
  }

  Future<Map<String, dynamic>> generateAIOutfit({
    required String season,
    required String weather,
    required String event,
    required String style,
    bool isHijab = false,
  }) async {
    try {
      final response = await _apiClient.client.post(
        '/outfits/generate',
        data: {
          'season': season,
          'weather': weather,
          'event': event,
          'style': style,
          'is_hijab': isHijab,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Kombin önerisi alınamadı: ${_handleError(e)}');
    }
  }

  Future<void> deleteOutfit(String id) async {
    try {
      await _apiClient.client.delete('/outfits/$id');
    } catch (e) {
      throw Exception('Kombin silinemedi: \${_handleError(e)}');
    }
  }

  Future<OutfitItem> toggleFavorite(String id) async {
    try {
      final response = await _apiClient.client.patch('/outfits/$id/favorite');
      return OutfitItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Favori durumu güncellenemedi: \${_handleError(e)}');
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

final outfitRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OutfitRepository(apiClient);
});
