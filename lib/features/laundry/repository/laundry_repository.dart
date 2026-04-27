import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/network/api_client.dart';
import 'package:gircik/data/models/laundry_item.dart';

class LaundryRepository {
  final ApiClient _apiClient;

  LaundryRepository(this._apiClient);

  Future<List<LaundryItem>> getLaundryItems() async {
    try {
      final response = await _apiClient.client.get('/laundry/');
      final data = response.data as List;
      return data.map((item) => LaundryItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Çamaşırlar getirilemedi: \${_handleError(e)}');
    }
  }

  Future<LaundryItem> updateStatus(String id, String newStatus) async {
    try {
      final response = await _apiClient.client.patch(
        '/laundry/$id/status',
        queryParameters: {'status': newStatus},
      );
      return LaundryItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Çamaşır durumu güncellenemedi: \${_handleError(e)}');
    }
  }

  Future<LaundryItem> incrementWear(String id) async {
    try {
      final response = await _apiClient.client.patch('/laundry/$id/wear');
      return LaundryItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Giyim sayısı artırılamadı: ${_handleError(e)}');
    }
  }

  Future<void> updateAllMaxWear(int maxWear) async {
    try {
      await _apiClient.client.patch(
        '/laundry/max-wear',
        queryParameters: {'max_wear': maxWear},
      );
    } catch (e) {
      throw Exception('Kullanım sınırı güncellenemedi: ${_handleError(e)}');
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

final laundryRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LaundryRepository(apiClient);
});
