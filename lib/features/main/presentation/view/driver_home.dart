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
    context.watch<DeliveryCubit>().state;

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
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: state.currentLocation,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _buildMarker(state.currentLocation),

              ),

       /*  ElevatedButton(onPressed: (){
           context.read<DeliveryCubit>().setShopLocation(
             const LatLng(33.5138, 36.2765),
           );

         },
             child: const Text("Select Delivery Location")),*/


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
              /*Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: size.height * 0.12,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 200,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColor.buttonMainColor,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    AppColor.buttonMainColor,
                                    borderRadius:
                                    BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    "Online",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),*/
              BlocBuilder<DeliveryCubit, DeliveryState>(
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
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isOnline ? "Online" : "Offline",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
