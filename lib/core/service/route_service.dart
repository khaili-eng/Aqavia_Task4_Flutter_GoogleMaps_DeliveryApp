

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:untitled18/core/service/route_result.dart';

class RouteService {

  static Future<List<LatLng>> getRouteOSRM(LatLng start, LatLng end) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);

    if (data['code'] != 'Ok') return [];

    final points = data['routes'][0]['geometry'];

    return decodePolyline(points);
  }
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
  }
  static Future<RouteResult?> getRouteWithInfo(LatLng start, LatLng end) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['code'] != 'Ok') return null;

    final route = data['routes'][0];
    final points = decodePolyline(route['geometry']);
    final distance = route['distance'] * 1.0; // بالميتر
    final duration = route['duration'] * 1.0; // بالثواني

    return RouteResult(points: points, distanceMeters: distance, durationSeconds: duration);
  }


}
