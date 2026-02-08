import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../order/data/models/order_model.dart';
import 'delivery_state.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  DeliveryCubit() : super(const DeliveryInitial());

  Timer? _animationTimer;


  void initializeOrder({
    required LatLng userLocation,
    required LatLng shopLocation,
  }) {
    final order = OrderModel(
      id: "ORD123",
      customerName: "John Doe",
      customerPhone: "+1234567890",
      item: "Tender Coconut",
      quantity: 4,
      price: 320,
      pickUpLocation: shopLocation,
      deliveryLocation: userLocation,
      pickUpAddress: "Kathmandu Durbar Square",
      deliveryAddress: "Patan Durbar Square",
    );

    emit(
      DeliveryInProgress(
        isOnline: true,
        status: DeliveryStatus.waitingForAcceptance,
        currentOrder: order,
        routePoints: const [],
        deliveryBoyPosition: null,
        polylines: const {},
        markers: const {},
      ),
    );
  }

//function to accept order
  void acceptOrder() {
    if (state is! DeliveryInProgress) return;

    final current = state as DeliveryInProgress;

    emit(current.copyWith(status: DeliveryStatus.pickingUp));

    Future.delayed(const Duration(seconds: 2), () {
      _generateRoute();
      _setupMap();
    });
  }
  //function to reject order and reset state
  void rejectOrder() {
    _stopAnimation();
    emit(const DeliveryRejected());
  }

//function to start pickup process
  void markAsPickedUp() {
    if (state is! DeliveryInProgress) return;

    final current = state as DeliveryInProgress;

    emit(current.copyWith(status: DeliveryStatus.enRoute));
    _startDeliverySimulation();
  }
//function to mark destination reached
  void completeDelivery() {
    _stopAnimation();
    emit(const DeliveryCompleted());
  }

  List<LatLng> _buildDynamicRoute(LatLng start, LatLng end) {
    const steps = 40;
    final random = Random();
    final List<LatLng> route = [];

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      route.add(
        LatLng(
          start.latitude +
              (end.latitude - start.latitude) * t +
              (random.nextDouble() - 0.5) * 0.0002,
          start.longitude +
              (end.longitude - start.longitude) * t +
              (random.nextDouble() - 0.5) * 0.0002,
        ),
      );
    }
    return route;
  }
//function to generate route between pickup and delivery location
  void _generateRoute() {
    if (state is! DeliveryInProgress) return;

    final current = state as DeliveryInProgress;

    final route = _buildDynamicRoute(
      current.currentOrder.pickUpLocation,
      current.currentOrder.deliveryLocation,
    );

    emit(
      current.copyWith(
        routePoints: route,
        deliveryBoyPosition: route.first,
      ),
    );
  }
//function to setup map polylines and markers
  void _setupMap() {
    if (state is! DeliveryInProgress) return;

    final current = state as DeliveryInProgress;

    final polylines = {
      Polyline(
        polylineId: const PolylineId("route"),
        points: current.routePoints,
        width: 5,
        color: Colors.blue,
      ),
    };

    final markers = {
      Marker(
        markerId: const MarkerId("pickup"),
        position: current.currentOrder.pickUpLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
      Marker(
        markerId: const MarkerId("delivery"),
        position: current.currentOrder.deliveryLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      ),
    };

    emit(
      current.copyWith(
        polylines: polylines,
        markers: markers,
      ),
    );

    _updateDeliveryBoyMarker();
  }
//function to update delivery boy marker on the map
  void _updateDeliveryBoyMarker() {
    if (state is! DeliveryInProgress) return;

    final current = state as DeliveryInProgress;

    final updatedMarkers = Set<Marker>.from(current.markers)
      ..removeWhere((m) => m.markerId.value == "delivery_boy");

    if (current.deliveryBoyPosition != null) {
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId("delivery_boy"),
          position: current.deliveryBoyPosition!,
          rotation: _calculateBearing(current),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    emit(current.copyWith(markers: updatedMarkers));
  }
  void _startDeliverySimulation() {
    if (state is! DeliveryInProgress) return;

    _animationTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) {
          final current = state as DeliveryInProgress;

          final index = current.routePoints.indexOf(
            current.deliveryBoyPosition!,
          );

          if (index < current.routePoints.length - 1) {
            emit(
              current.copyWith(
                deliveryBoyPosition: current.routePoints[index + 1],
              ),
            );
            _updateDeliveryBoyMarker();
          } else {
            _stopAnimation();
            emit(current.copyWith(
              status: DeliveryStatus.destinationReached,
            ));
          }
        });
  }
  //function to toggle bettween online and offline status
  void toggleOnline() {
    if (state is DeliveryInProgress) {
      final current = state as DeliveryInProgress;
      emit(current.copyWith(isOnline: !current.isOnline));
    } else {
      emit(const DeliveryInitial());
    }
  }
//function to load order deatails

  double _calculateBearing(DeliveryInProgress state) {
    final index =
    state.routePoints.indexOf(state.deliveryBoyPosition!);

    if (index <= 0) return 0;

    final prev = state.routePoints[index - 1];
    final curr = state.routePoints[index];

    final lat1 = prev.latitude * pi / 180;
    final lon1 = prev.longitude * pi / 180;
    final lat2 = curr.latitude * pi / 180;
    final lon2 = curr.longitude * pi / 180;

    final y = sin(lon2 - lon1) * cos(lat2);
    final x = cos(lat1) * sin(lat2) -
        sin(lat1) * cos(lat2) * cos(lon2 - lon1);

    return (atan2(y, x) * 180 / pi + 360) % 360;
  }
  void resetDelivery() {
    _stopAnimation();
    emit(const DeliveryInitial());
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  @override
  Future<void> close() {
    _stopAnimation();
    return super.close();
  }
}