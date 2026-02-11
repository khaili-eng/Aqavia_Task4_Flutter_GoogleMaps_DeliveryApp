import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<LatLng?> searchLocation(String query) async {
  final url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1';

  final response = await http.get(
    Uri.parse(url),
    headers: {"User-Agent": "YourAppName"},
  );

  if (response.statusCode != 200) return null;

  final data = json.decode(response.body) as List<dynamic>;
  if (data.isEmpty) return null;
  final firstResult = data[0];
  final lat = double.parse(firstResult['lat']);
  final lon = double.parse(firstResult['lon']);

  return LatLng(lat, lon);
}