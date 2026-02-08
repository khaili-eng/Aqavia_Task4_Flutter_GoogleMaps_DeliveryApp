import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
@HiveType(typeId: 0)
class OrderModel extends HiveObject{
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String customerName;
  @HiveField(2)
  final String customerPhone;
  @HiveField(3)
  final String item;
  @HiveField(4)
  final int quantity;
  @HiveField(5)
  final int price;
  @HiveField(6)
  final LatLng pickUpLocation;
  @HiveField(7)
  final LatLng deliveryLocation;
  @HiveField(8)
  final String pickUpAddress;
  @HiveField(9)
  final String deliveryAddress;
  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.item,
    required this.quantity,
    required this.price,
    required this.pickUpLocation,
    required this.deliveryLocation,
    required this.pickUpAddress,
    required this.deliveryAddress,
});
}