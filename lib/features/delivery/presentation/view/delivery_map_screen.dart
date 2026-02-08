import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:untitled18/core/color/app_color.dart';
import 'package:untitled18/features/delivery/presentation/manager/delivery_cubit.dart';
import 'package:untitled18/features/delivery/presentation/manager/delivery_state.dart';
import 'package:untitled18/features/delivery/presentation/widgets/order_on_the_way.dart';
import 'package:untitled18/features/main/presentation/widgets/custom_button.dart';

class DeliveryMapScreen extends StatefulWidget {
  DeliveryMapScreen({super.key});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  GoogleMapController? _mapController;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeliveryCubit(),
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        body: BlocBuilder<DeliveryCubit, DeliveryState>(
          builder: (context, state) {
            return Stack(
              children: [

                _buildMap(state),

                if (_shouldShowOrderCard(state))
                  _buildOrderCard(context, state as DeliveryInProgress),

                if (state is DeliveryCompleted)
                  _buildDeliveryCompletedCard(context),
              ],
            );
          },
        ),
      ),
    );
  }


  Widget _buildMap(DeliveryState state) {
    final LatLng startLocation = _getInitialCameraPosition(state);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: startLocation,
        zoom: 14,
      ),
      onMapCreated: (controller) {
        _mapController = controller;

        if (state is DeliveryInProgress) {
          _moveCamera(state.currentOrder.pickUpLocation);
        }
      },
      markers: _buildMarkers(state),
      polylines: _buildPolylines(state),
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
    );
  }

  LatLng _getInitialCameraPosition(DeliveryState state) {
    if (state is DeliveryInProgress) {
      return state.currentOrder.pickUpLocation;
    }
    return const LatLng(37.7749, -122.4194); // default
  }

  Set<Marker> _buildMarkers(DeliveryState state) {
    if (state is! DeliveryInProgress) return {};

    final markers = <Marker>{};

    // Pickup marker
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: state.currentOrder.pickUpLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
    );

    // Delivery marker
    markers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: state.currentOrder.deliveryLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      ),
    );

    // Delivery boy marker
    if (state.deliveryBoyPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery_boy'),
          position: state.deliveryBoyPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );

      _moveCamera(state.deliveryBoyPosition!);
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(DeliveryState state) {
    if (state is! DeliveryInProgress) return {};

    if (state.routePoints.isEmpty ||
        state.status == DeliveryStatus.waitingForAcceptance ||
        state.status == DeliveryStatus.rejected) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: state.routePoints,
        color: AppColor.buttonMainColor,
        width: 6,
      ),
    };
  }

  bool _shouldShowOrderCard(DeliveryState state) {
    return state is DeliveryInProgress &&
        state.status != DeliveryStatus.rejected;
  }

  Widget _buildOrderCard(
      BuildContext context,
      DeliveryInProgress state,
      ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: OrderOnTheWay(
          order: state.currentOrder,
          status: state.status,
          onButtonPressed: () {
            final cubit = context.read<DeliveryCubit>();

            switch (state.status) {
              case DeliveryStatus.pickingUp:
                cubit.markAsPickedUp();
                break;
              case DeliveryStatus.destinationReached:
                cubit.completeDelivery();
                break;
              case DeliveryStatus.markingAsDelivered:
                cubit.completeDelivery();
                break;
              default:
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildDeliveryCompletedCard(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black12,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Delivery Completed!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You have successfully completed the delivery.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    title: "Go To Home Screen",
                    onPressed: () {
                      context.read<DeliveryCubit>().resetDelivery();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _moveCamera(LatLng location) {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(location, 14),
    );
  }
}