import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_state.dart';
//location cubit
class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationState.initial()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: '',
      ));

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage:
            'Location permission denied. Using default location.',
          ));
          return;
        }
      }
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Location services are disabled.',
        ));
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      emit(state.copyWith(
        currentLocation:
        LatLng(position.latitude, position.longitude),
        isLoading: false,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage:
        'Something went wrong: ${e.toString()}. Using default location.',
      ));
    }
  }


  void refreshLocation() {
    getCurrentLocation();
  }
}
//bottom navigation cubit
class NavigationCubit extends Cubit<int>{
  NavigationCubit():super(0);
  void goToHome()=>emit(0);
  void goToOrder()=>emit(1);
  void goToUsers()=>emit(2);
}