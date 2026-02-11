import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../delivery/presentation/manager/delivery_cubit.dart';
import '../../../delivery/presentation/manager/delivery_state.dart';

class RoutePreviewMapScreen extends StatelessWidget {
  const RoutePreviewMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route Preview")),
      body: BlocBuilder<DeliveryCubit, DeliveryState>(
        builder: (context, state) {
          if (state is! DeliveryInProgress ||
              state.routePoints.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children:[
              GoogleMap(
              initialCameraPosition: CameraPosition(
                target: state.routePoints.first,
                zoom: 13,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: state.routePoints,
                  color: Colors.blue,
                  width: 6,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId("start"),
                  position: state.currentOrder.pickUpLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
                Marker(
                  markerId: const MarkerId("end"),
                  position: state.currentOrder.deliveryLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
            ),
              RoutePreviewCard(state),
          ]
          );
        },
      ),
    );
  }
}
Widget RoutePreviewCard(DeliveryInProgress state) {
  final duration = state.durationSeconds ?? 0.0;
  final distance = state.distanceMeters ?? 0.0;
  final price = state.estimatedPrice ?? 0.0;
  return Positioned(
    top: 20,
    left: 16,
    right: 16,
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _infoItem(
              Icons.timer,
              formatDuration(duration),
            ),
            _infoItem(
              Icons.route,
              formatDistance(distance),
            ),
            _infoItem(
              Icons.attach_money,
              price.toStringAsFixed(1),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _infoItem(IconData icon, String value) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.blue),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
String formatDistance(double meters) {
  return (meters / 1000).toStringAsFixed(1) + " كم";
}

String formatDuration(double seconds) {
  final minutes = (seconds / 60).round();
  return "$minutes دقيقة";
}