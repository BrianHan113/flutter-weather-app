import 'dart:convert';
import 'dart:typed_data';

import 'package:geolocator/geolocator.dart';
import 'package:weather_app/geo_location.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GetData {
  final GeoLocation geo = GeoLocation();
  var uri;

  Future<Position> getPosition() async {
    try {
      Position position = await geo.determinePosition();
      return position;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<WeatherData> getData() async {
    Position position = await getPosition();
    uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': '${position.latitude}',
      'lon': '${position.longitude}',
      'appid': dotenv.env['OPEN_WEATHER_API'],
      'units': 'metric',
      'lang': 'en'
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return WeatherData.fromJson(jsonData);
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<Uint8List> fetchImage() async {
    Position position = await getPosition();

    final response = await http.get(Uri.parse(
        'https://api.niwa.co.nz/uv/chart.png?apikey=${dotenv.env['NIWA_API']}&lat=${position.latitude}&long=${position.longitude}'));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }
}
