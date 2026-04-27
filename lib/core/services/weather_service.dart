import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherInfo {
  final String condition; // Güneşli, Yağmurlu, Bulutlu, Karlı
  final double temperature;
  final String city;
  final String advice;

  WeatherInfo({
    required this.condition,
    required this.temperature,
    required this.city,
    required this.advice,
  });
}

class WeatherService {
  final Dio _dio = Dio();

  Future<WeatherInfo> getCurrentWeather() async {
    try {
      // 1. Konum al
      Position position = await _determinePosition();
      
      // 2. Şehir adını al (Reverse Geocoding)
      String cityName = 'Mevcut Konum';
      try {
        await setLocaleIdentifier('tr_TR');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          cityName = place.administrativeArea ?? place.locality ?? place.subAdministrativeArea ?? 'Mevcut Konum';
        }
      } catch (e) {
        print('Geocoding Error: $e');
      }
      
      // 3. Open-Meteo API'den hava durumu çek (API KEY Gerektirmez)
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current_weather=true';
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final data = response.data['current_weather'];
        final double temp = data['temperature'];
        final int weatherCode = data['weathercode'];
        
        final condition = _mapWeatherCodeToCondition(weatherCode);
        final advice = _generateAdvice(condition, temp);
        
        return WeatherInfo(
          condition: condition,
          temperature: temp,
          city: cityName,
          advice: advice,
        );
      }
      throw Exception('Hava durumu verisi alınamadı');
    } catch (e) {
      print('Weather Error: $e');
      // Hata durumunda güvenli bir mock veri dönelim
      return WeatherInfo(
        condition: 'Güneşli',
        temperature: 20.0,
        city: 'Konum Alınamadı',
        advice: 'Hava durumuna erişilemedi, ancak dışarıya göre giyinmeyi unutma!',
      );
    }
  }

  String _mapWeatherCodeToCondition(int code) {
    if (code == 0) return 'Güneşli';
    if (code >= 1 && code <= 3) return 'Bulutlu';
    if (code >= 61 && code <= 67) return 'Yağmurlu';
    if (code >= 80 && code <= 82) return 'Yağmurlu';
    if (code >= 71 && code <= 77) return 'Karlı';
    if (code >= 95 && code <= 99) return 'Yağmurlu';
    return 'Bulutlu';
  }

  String _generateAdvice(String condition, double temp) {
    if (condition == 'Yağmurlu') return 'Bugün hava yağmurlu görünüyor, şemsiyeni almayı sakın unutma!';
    if (condition == 'Karlı') return 'Hava çok soğuk ve karlı! Sıkı giyin ve atkını unutma.';
    if (temp < 15) return 'Hava biraz serin olabilir, yanına bir ceket veya hırka almanı öneririm.';
    if (temp > 25) return 'Hava oldukça sıcak! İnce kıyafetler seçip bol su içmeyi ihmal etme.';
    return 'Hava harika görünüyor! Keyfini çıkar ve tarzını yansıt.';
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisleri kapalı.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni kalıcı olarak reddedildi.');
    } 

    return await Geolocator.getCurrentPosition();
  }
}

final weatherServiceProvider = Provider((ref) => WeatherService());
