import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:untitled18/core/service/location_search_service.dart';

import '../../../../core/service/navigation_search.dart';
import '../../../../core/service/route_service.dart';
import '../../../main/presentation/manager/location_cubit.dart';
import '../../../order/data/models/order_model.dart';
import 'delivery_state.dart';
import 'package:untitled18/features/delivery/presentation/manager/delivery_cubit.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  DeliveryCubit() : super(const DeliveryInitial());

  Timer? _animationTimer;
  final TextEditingController searchController = TextEditingController();


  void initializeOrder({
    required LatLng userLocation,
    required LatLng shopLocation,
  }) {
    final order = OrderModel(
      id: "ORD123",
      customerName: "Mohammad",
      customerPhone: "+963xxxxxxxxx",
      item: "Tender Coconut",
      quantity: 4,
      price: 320,
      pickUpLocation: shopLocation,
      deliveryLocation: userLocation,
      pickUpAddress: "Tartous ",
      deliveryAddress: "Safita",
    );

    emit(
      DeliveryInProgress(
        isOnline: true,
        userLocation: userLocation,
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

    emit(current.copyWith(status: DeliveryStatus.orderAccepted));

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

    emit(current.copyWith(status: DeliveryStatus.pickingUp));
    _generateRoute();
    _setupMap();
    _startDeliverySimulation();
  }
//function to mark destination reached
  void completeDelivery() {
    _stopAnimation();
    emit(const DeliveryCompleted());
  }


  Future<void> generateRealisticRoute() async {
    if (state is! DeliveryInProgress) return;

    final current = state as DeliveryInProgress;

    final routePoints = await RouteService.getRouteOSRM(
      current.currentOrder.pickUpLocation,
      current.currentOrder.deliveryLocation,
    );

    emit(current.copyWith(
      routePoints: routePoints,
      deliveryBoyPosition: routePoints.isNotEmpty ? routePoints.first : null,
    ));
  }
  Future<void> generateRouteFromSearch({required String startQuery, required String destinationQuery}) async{
final startLatLng = await searchLocation(startQuery);
final destinationLatLng = await searchLocation(destinationQuery);
if (startLatLng == null || destinationLatLng == null) return;
final routePoints =
await RouteService.getRouteWithInfo(
startLatLng,
destinationLatLng,
);
if (routePoints == null) return;
final distanceKm = routePoints.distanceMeters / 1000;
final estimatedPrice = 5 + (distanceKm * 2);

emit(DeliveryInProgress(
    status: DeliveryStatus.waitingForAcceptance,
    currentOrder: OrderModel(
      id: "SEARCH",
      customerName: "",
      customerPhone: "",
      item: "",
      quantity: 0,
      price: 0,
      pickUpLocation: startLatLng,
      deliveryLocation: destinationLatLng,
      pickUpAddress: startQuery,
      deliveryAddress: destinationQuery,
    ),
    routePoints: routePoints.points,
    deliveryBoyPosition: routePoints.points.first,
    distanceMeters: routePoints.distanceMeters,
    durationSeconds: routePoints.durationSeconds,
    estimatedPrice: estimatedPrice,
    polylines: const{},
    markers: const{})
);
_setupSearchMap();
  }

  Future<void> searchAndGenerateRoute(
      LatLng userLocation,
      String destination,
      ) async {

    final routePoints =
    await generateRouteToLocation(userLocation, destination);

    if (routePoints.isEmpty) return;


    if (state is DeliveryInProgress) {
      final current = state as DeliveryInProgress;

      emit(
        current.copyWith(
          routePoints: routePoints,
          deliveryBoyPosition: routePoints.first,
        ),
      );
    }

    else {
      emit(
        DeliveryInProgress(
          userLocation: userLocation,
          status: DeliveryStatus.waitingForAcceptance,
          currentOrder: OrderModel(
            id: "SEARCH",
            customerName: "",
            customerPhone: "",
            item: "",
            quantity: 0,
            price: 0,
            pickUpLocation: userLocation,
            deliveryLocation: routePoints.last,
            pickUpAddress: "Current Location",
            deliveryAddress: destination,
          ),
          routePoints: routePoints,
          deliveryBoyPosition: routePoints.first,
          polylines: const {},
          markers: const {},
          isOnline: true,
        ),
      );
    }

    _setupSearchMap();
  }
//function to generate route between pickup and delivery location
  void _generateRoute() async {
    if (state is! DeliveryInProgress) return;

    final current = state as DeliveryInProgress;

    final route = await RouteService.getRouteOSRM(
      current.currentOrder.pickUpLocation,
      current.currentOrder.deliveryLocation,
    );
    if (route.isEmpty) return;

    emit(
      current.copyWith(
        routePoints: route,
        deliveryBoyPosition: route.first,
      ),
    );
  }
  void _setupSearchMap() {
    if (state is! DeliveryInProgress) return;

    final current = state as DeliveryInProgress;

    if (current.routePoints.isEmpty) return;

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
        markerId: const MarkerId("start"),
        position: current.routePoints.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
      Marker(
        markerId: const MarkerId("destination"),
        position: current.routePoints.last,
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