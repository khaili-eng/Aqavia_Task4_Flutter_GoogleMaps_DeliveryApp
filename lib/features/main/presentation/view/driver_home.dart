import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:untitled18/features/order/data/models/order_model.dart';

import '../../../../core/color/app_color.dart';
import '../../../../core/utils/utils.dart';

import '../../../delivery/presentation/manager/delivery_cubit.dart';
import '../../../delivery/presentation/manager/delivery_state.dart';
import '../manager/location_cubit.dart';
import '../manager/location_state.dart';
import '../widgets/order_card.dart';

class DriverHome extends StatelessWidget {
  
  const DriverHome({super.key,});

  Set<Marker> _buildMarker(LatLng currentLocation) {
    return {
      Marker(
        markerId: const MarkerId("current_location"),
        position: currentLocation,
        infoWindow: const InfoWindow(
          title: "Current Location",
          snippet: "You are here!",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final deliveryCubit = context.read<DeliveryCubit>();
    Future.microtask(() {
      if (deliveryCubit.state is DeliveryInitial) {
        deliveryCubit.initializeOrder(
          userLocation: const LatLng(34.82099, 36.11773), // موقع المستخدم
          shopLocation: const LatLng(34.8820, 35.9000), // موقع المتجر
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Getting your location..."),
                ],
              ),
            );
          }

          if (state.errorMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showAppSnackbar(
                context: context,
                type: SnackbarType.error,
                description: state.errorMessage,
              );
            });
          }

          final size = MediaQuery.of(context).size;

          return Stack(
            children: [
              BlocBuilder<DeliveryCubit, DeliveryState>(
                builder: (context, deliveryState) {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: state.currentLocation, // من LocationCubit
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    markers: deliveryState is DeliveryInProgress &&
                        deliveryState.markers.isNotEmpty
                        ? deliveryState.markers
                        : _buildMarker(state.currentLocation),

                    polylines: deliveryState is DeliveryInProgress
                        ? deliveryState.polylines
                        : {},
                  );
                },
              ),
              Positioned(
                top: 80,
                left: 16,
                right: 16,
                child: _buildSearchBar(context),
              ),



              BlocBuilder<DeliveryCubit, DeliveryState>(
                builder: (context, deliveryState) {
                  if (deliveryState.status == DeliveryStatus.waitingForAcceptance &&
                      deliveryState.currentOrder != null) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: OrderCard(
                          order: deliveryState.currentOrder!,
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              /// 🟢 Online Button

              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: BlocBuilder<DeliveryCubit, DeliveryState>(
                    builder: (context, state) {
                      final isOnline = state.isOnline;

                      return GestureDetector(
                        onTap: () {
                          context.read<DeliveryCubit>().toggleOnline();
                        },
                        child: Container(
                          width: 200,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isOnline ? "Online" : "Offline",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
Widget _buildSearchBar(BuildContext context) {
  final deliveryCubit = context.read<DeliveryCubit>();
  final locationCubit = context.read<LocationCubit>();

  return Material(
    elevation: 6,
    borderRadius: BorderRadius.circular(12),
    child: TextField(
      controller: deliveryCubit.searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        final destination = value.trim();
        if (destination.isNotEmpty) {
          deliveryCubit.searchAndGenerateRoute(
            locationCubit.state.currentLocation,
            destination,
          );
        }
      },
      decoration: InputDecoration(
        hintText: "Enter your destination",
        prefixIcon: const Icon(Icons.location_on_outlined),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            final destination =
            deliveryCubit.searchController.text.trim();
            if (destination.isNotEmpty) {
              deliveryCubit.searchAndGenerateRoute(
                locationCubit.state.currentLocation,
                destination,
              );
            }
          },
        ),
        border: InputBorder.none,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}