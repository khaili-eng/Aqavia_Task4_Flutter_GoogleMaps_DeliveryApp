import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled18/core/color/app_color.dart';
import 'package:untitled18/features/delivery/presentation/manager/delivery_cubit.dart';
import 'package:untitled18/features/main/presentation/widgets/custom_button.dart';
import 'package:untitled18/features/main/presentation/widgets/dash_vertical_line.dart';
import 'package:untitled18/features/order/data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel? order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //new order available header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Text(" New Order Available",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black12,
                ),
                ),
                SizedBox(width: 15,),
                Text("\$${order?.price}",style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black12,
                ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close),
                )
              ],
            ),
          ),
          //order details
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.white,
                  elevation: 1,
                  shadowColor: Colors.black12,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: NetworkImage(""))
                        ),
                      ),
                      SizedBox(width: 12,),
                      Text.rich(TextSpan(style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16
                      ),
                        children: [
                          TextSpan(text: "tender Cocount (Normal)"),
                          TextSpan(text: "${order?.quantity}",style: TextStyle(color: Colors.black12)),
                        ]
                      ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                //pick and delivery
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.radio_button_checked,color: AppColor.iconColor,size: 20,),
                        SizedBox(height: 35,
                          child: DashVerticalLine(
                              dashHeight: 6,dashGap: 5, ),
                        ),
                      ],
                    ),
                    SizedBox(width: 4,),
                    pickupAndDeliveryInfo("Pickup -", order?.pickUpAddress, "Green Vally Cocount store")
                  ],
                ),
                //step 2 delivery
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,color: AppColor.iconColor,),
                    SizedBox(width: 5,),
                    pickupAndDeliveryInfo("Delivery - ",order?.deliveryAddress, order?.customerName)
                  ],
                ),
                SizedBox(height: 12,),
                //action button
                SizedBox(
                  width: double.maxFinite,
                  child: CustomButton(title: "View Order Details",
                      onPressed: (){
                    final order = context.read<DeliveryCubit>().state.currentOrder;
                    if(order == null) return;
                    context.pushNamed("order_details",pathParameters: {"id": order.id});


                      }),)
              ],
            ),
          )
        ],
      ),
    );
  }
  Expanded pickupAndDeliveryInfo(title,address,subtitle){
    return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                    child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    )
                ),
                Expanded(
                    flex: 9,
                    child: Text(address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    )
                ),
              ],
            ),
            Text(subtitle,style: TextStyle(color: Colors.black12),)
          ],
        ));
  }
}
