import 'package:flutter/material.dart';
import 'package:untitled18/core/color/app_color.dart';

import 'package:untitled18/features/main/presentation/widgets/custom_button.dart';
import 'package:untitled18/features/order/data/models/order_model.dart';

import '../manager/delivery_state.dart';

class OrderOnTheWay extends StatelessWidget {
  final OrderModel order;
  final DeliveryStatus status;
  final VoidCallback onButtonPressed;

  const OrderOnTheWay({super.key,
    required this.order,
    required this.status,
    required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10,),
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          //pickup location row with icon,text,phone
          ListTile(
            leading: Icon(_getPickupIcon(), color: _getPickupIconColor(),),
            title: Text(
              "Pickup Location",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(order.pickUpAddress),
            trailing: CircleAvatar(
              radius: 18,
              backgroundColor: AppColor.buttonMainColor,
              child: Icon(Icons.phone, color: Colors.white,),
            ),
          ),
          //delivery location row with icon,text and phone
          ListTile(
            leading: Icon(_getDeliveryIcon(),color: _getDeliveryIconColor(),),
            title: Text("Delivery - ${order.customerName}",
            style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
            subtitle: Text(order.deliveryAddress),
            trailing: CircleAvatar(
              radius: 18,
              backgroundColor: AppColor.buttonMainColor,
              child: Icon(Icons.phone,color: Colors.white,),
            ),
          ),
          Padding(padding: EdgeInsets.all(20),child: SizedBox(width: double.maxFinite,child: _buttonStyle(),),)
        ],
      ),
    );
  }

  //return appropriate icon from pickup location base on status
  IconData _getPickupIcon() {
    switch (status) {
      case DeliveryStatus.enRoute:
      case DeliveryStatus.destinationReached:
      case DeliveryStatus.markingAsDelivered:
      case DeliveryStatus.delivered:
        return Icons.check_circle; //red check icon when picked up
      default:
        return Icons.radio_button_checked;
    }
  }

//return color for pickup icon based on status
  Color _getPickupIconColor() {
    switch (status) {
      case DeliveryStatus.enRoute:
      case DeliveryStatus.destinationReached:
      case DeliveryStatus.markingAsDelivered:
      case DeliveryStatus.delivered:
        return AppColor.buttonMainColor;
      default:
        return Colors.grey;
    }
  }

//return appropriate icon for pickup/delivery  location based on status
  IconData _getDeliveryIcon() {
    switch (status) {
      case DeliveryStatus.markingAsDelivered:
      case DeliveryStatus.delivered:
      //check only after "mark as destination reached'
        return Icons.check_circle;
      default:
      // location pin until user clicks "mark as destination reached"
        return Icons.location_on_outlined;
    }
  }

//return color for pickup/delivery  location based on status
  Color _getDeliveryIconColor() {
    switch (status) {
      case DeliveryStatus.markingAsDelivered:
      case DeliveryStatus.delivered:
        return AppColor.buttonMainColor;
      default:
        return Colors.grey;
    }
  }
  //return button widget basee on current delivery status
Widget _buttonStyle(){
    switch (status){
      case DeliveryStatus.destinationReached:
        //special button style with arrow icon when destination is reached
        return Padding(padding: EdgeInsets.symmetric(horizontal: 18),
        child: GestureDetector(
          onTap: _isButtonEnabled()?(onButtonPressed??(){}):(){},
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                padding: EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: AppColor.pickedUpColor.withAlpha(170),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
                ),
                child: Icon(Icons.arrow_forward,color: Colors.white,),
              ),
              ),
              Expanded(
                flex: 17,
                child: Container(
                padding: EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: _getButtonColor(),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(30),
                  ),
                ),
                child: Center(child: Text(_getButtonText(),style: TextStyle(color: Colors.black12,fontSize: 16,fontWeight: FontWeight.w600),),),
              ),
              )
            ],
          ),
        ),
        );
      default:
        //standard button style for other statuses
        return CustomButton(title: _getButtonText(), onPressed: _isButtonEnabled()?(onButtonPressed??(){}):(){},
        color: _getButtonColor(),);
    }
}
//return button color based on delivery status
  Color _getButtonColor() {
    switch (status) {
      case DeliveryStatus.pickingUp:
        return AppColor.pickedUpColor;
      case DeliveryStatus.enRoute:
        return Colors.grey;
      case DeliveryStatus.destinationReached:
        return AppColor.pickedUpColor;
      case DeliveryStatus.markingAsDelivered:
        return AppColor.buttonMainColor;
      case DeliveryStatus.delivered:
        return Colors.red.withAlpha(150);
      default:
        return AppColor.buttonMainColor;
    }
  }
//return button text based on delivery status
String _getButtonText(){
    switch (status){
      case DeliveryStatus.pickingUp:
        return "Mark as Picked Up";
      case DeliveryStatus.enRoute:
        return "Delivering ...";
      case DeliveryStatus.destinationReached:
        return "Mark as Delivered";
      case DeliveryStatus.markingAsDelivered:
        return "Marking as Delivered...";
      case DeliveryStatus.delivered:
        return "Delivered";
      default:
        return "Delivery Completed";
    }
}
//return whether button shold be enabled/clickable
bool _isButtonEnabled(){
    switch(status){
      case DeliveryStatus.enRoute:
      case DeliveryStatus.delivered:
        return false;
      default:
        return true;
    }
}
}
