import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_search_service.dart';
import 'route_service.dart';

Future<List<LatLng>> generateRouteToLocation(LatLng userLocation, String destination) async {
  final destinationLatLng = await searchLocation(destination);
  if (destinationLatLng == null) return [];
  final routePoints = await RouteService.getRouteOSRM(
    userLocation,
    destinationLatLng,
  );
  return routePoints;
}