import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState extends Equatable {
  final LatLng currentLocation;
  final bool isLoading;
  final String errorMessage;

  const LocationState({
    required this.currentLocation,
    required this.isLoading,
    required this.errorMessage,
  });

  factory LocationState.initial() {
    return const LocationState(
      currentLocation: LatLng(230, 258), // default location
      isLoading: true,
      errorMessage: '',
    );
  }

  LocationState copyWith({
    LatLng? currentLocation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
    currentLocation,
    isLoading,
    errorMessage,
  ];
}
