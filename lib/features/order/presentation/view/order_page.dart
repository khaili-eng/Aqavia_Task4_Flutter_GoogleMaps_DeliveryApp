import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled18/core/color/app_color.dart';
import 'package:untitled18/features/delivery/presentation/manager/delivery_cubit.dart';
import 'package:untitled18/features/order/presentation/view/route_preview_map_page.dart';

import '../../../delivery/presentation/view/delivery_map_screen.dart';

class OrderPage extends StatelessWidget {
  OrderPage({super.key});
final TextEditingController startLocation = TextEditingController();
final TextEditingController destinationLocation = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeliveryCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Start Search"),
        centerTitle: true,
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
      child:Column(
        children: [
          _buildField(
              controller: startLocation,
              hint: "Start point",
              icon: Icons.my_location),
          SizedBox(height: 12,),
          _buildField(
              controller: destinationLocation,
              hint: "Destination",
              icon: Icons.location_on),
          SizedBox(height: 24,),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: (){
                  final start = startLocation.text.trim();
                  final end = destinationLocation.text.trim();
                  if (start.isEmpty || end.isEmpty) return;
                  cubit.generateRouteFromSearch(
                      startQuery: start,
                      destinationQuery: end);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: RoutePreviewMapScreen(),
                      )
                  ),
                  );
                },
                
                child: Text("Start",style: TextStyle(color: AppColor.iconColor),)),
          )

        ],
      ) ,),
    );
  }
}
Widget _buildField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
}) {
  return Material(
    elevation: 4,
    borderRadius: BorderRadius.circular(12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: InputBorder.none,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}
