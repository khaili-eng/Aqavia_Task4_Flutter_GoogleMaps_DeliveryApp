import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../order/data/models/order_model.dart';

enum DeliveryStatus {

  waitingForAcceptance,
  orderAccepted,
  pickingUp,
  enRoute,
  destinationReached,
  markingAsDelivered,
  delivered,
  rejected,
}
abstract class DeliveryState extends Equatable {
  final bool isOnline;
  final DeliveryStatus status;
  final String errorMessage;
  final OrderModel? currentOrder;
  const DeliveryState({this.isOnline = false, this.currentOrder,required this.status,this.errorMessage = ''});

  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {
  const DeliveryInitial(): super(isOnline: false, status: DeliveryStatus.waitingForAcceptance);
}

class DeliveryInProgress extends DeliveryState {
  final DeliveryStatus status;
  final OrderModel currentOrder;

  final List<LatLng> routePoints;
  final LatLng? deliveryBoyPosition;

  final Set<Polyline> polylines;
  final Set<Marker> markers;

  const DeliveryInProgress({
    required this.status,
    required this.currentOrder,
    required this.routePoints,
    required this.deliveryBoyPosition,
    required this.polylines,
    required this.markers,
    bool isOnline =false,
  }) : super(isOnline: isOnline, status: status);


  DeliveryInProgress copyWith({
    DeliveryStatus? status,
    List<LatLng>? routePoints,
    LatLng? deliveryBoyPosition,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    bool? isOnline,
  }) {
    return DeliveryInProgress(
      status: status ?? this.status,
      currentOrder: currentOrder,
      routePoints: routePoints ?? this.routePoints,
      deliveryBoyPosition:
      deliveryBoyPosition ?? this.deliveryBoyPosition,
      polylines: polylines ?? this.polylines,
      markers: markers ?? this.markers,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentOrder,
    routePoints,
    deliveryBoyPosition,
    polylines,
    markers,
  ];
}

class DeliveryCompleted extends DeliveryState {
  const DeliveryCompleted() : super(
    isOnline: true,
    status: DeliveryStatus.delivered,
    currentOrder: null,

  );
}

class DeliveryRejected extends DeliveryState {
  const DeliveryRejected(): super(
    isOnline: true,
    status: DeliveryStatus.rejected,
    currentOrder: null,
  );
}