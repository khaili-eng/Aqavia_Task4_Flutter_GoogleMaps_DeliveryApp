import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/color/app_color.dart';
import '../../../../core/utils/utils.dart';
import '../../../delivery/presentation/manager/delivery_cubit.dart';
import '../../../delivery/presentation/manager/delivery_state.dart';
import '../../../delivery/presentation/view/delivery_map_screen.dart';
import '../../../main/presentation/widgets/custom_button.dart';
import '../../data/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        title: const Text("Order Details"),
        centerTitle: true,
      ),
      body: BlocBuilder<DeliveryCubit, DeliveryState>(
        builder: (context, state) {
          final OrderModel? order = state.currentOrder;

          if (order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _customerInfo(order),
                const SizedBox(height: 12),
                _orderSummary(order),
                const SizedBox(height: 12),
                _pickupAndDelivery(order),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<DeliveryCubit, DeliveryState>(
        builder: (context, state) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: _buildBottomActions(context, state),
          );
        },
      ),
    );
  }



  Widget _customerInfo(OrderModel order) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCVk34DPmi_H0yY1SBbd61RJi4WfegVpcwGA&s",
          ),
        ),
        title: Text(
          order.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Order #${order.id}"),
        trailing: CircleAvatar(
          backgroundColor: AppColor.iconColor,
          child: const Icon(Icons.phone, color: Colors.white),
        ),
      ),
    );
  }

  Widget _orderSummary(OrderModel order) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.credit_card),
            const SizedBox(width: 10),
            Text(
              "${order.price}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickupAndDelivery(OrderModel order) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.radio_button_checked, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(child: Text(order.pickUpAddress)),
                Transform.rotate(
                  angle: -pi / 4,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text(order.deliveryAddress)),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildBottomActions(BuildContext context, DeliveryState state) {
    if (state.status == DeliveryStatus.orderAccepted) {
      return CustomButton(
        title: "Start Pickup",
        onPressed: () {
          context.read<DeliveryCubit>().markAsPickedUp();
        },
      );
    }
    if (state.status == DeliveryStatus.pickingUp) {
      return CustomButton(
        title: "On The Way",
        onPressed: () {
          final cubit= context.read<DeliveryCubit>();
          cubit.markAsPickedUp();
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (_) => BlocProvider.value(
          value: cubit, // نمرر نفس الـ Cubit
          child: DeliveryMapScreen(),
          ),
          ),
          );
        //  context.read<DeliveryCubit>().markAsOnTheWay();
        },
      );
    }

    if (state.status == DeliveryStatus.waitingForAcceptance) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              color: AppColor.pickedUpColor,
              textColor: Colors.black,
              title: 'Decline Order',
              onPressed: () {
                context.read<DeliveryCubit>().rejectOrder();
                Navigator.pop(context);
                showAppSnackbar(
                  context: context,
                  type: SnackbarType.error,
                  description: "Order rejected",
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomButton(
              color: AppColor.buttonMainColor,
              textColor: Colors.white,
              title: 'Accept Order',
              onPressed: () {
                context.read<DeliveryCubit>().acceptOrder();
                showAppSnackbar(
                  context: context,
                  type: SnackbarType.success,
                  description: "Order accepted",
                );
              },
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}