import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:untitled18/core/color/app_color.dart';
import 'package:untitled18/features/delivery/presentation/manager/delivery_cubit.dart';
import 'package:untitled18/features/main/presentation/manager/location_cubit.dart';
import 'package:untitled18/features/main/presentation/view/driver_home.dart';
import 'package:untitled18/features/order/presentation/view/order_page.dart';
import 'package:untitled18/features/user/presentation/view/users_page.dart';

class MainScreen extends StatefulWidget {

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPage = 0;

  final List<Widget> pages = [
    DriverHome(),
    OrderPage(),
    UsersPage(),
  ];

  final List<IconData> _icons = [
    FontAwesomeIcons.house,
    FontAwesomeIcons.boxOpen,
    FontAwesomeIcons.solidCircleUser,
  ];

  final List<String> _labels = [
    "Home",
    "Orders",
    "Profile",
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          return pages[currentIndex];
        },
      ),

      bottomNavigationBar: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          return Container(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_icons.length, (index) {
                final bool isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    final cubit = context.read<NavigationCubit>();
                    if(index == 0) cubit.goToHome();
                    else if(index == 1) cubit.goToOrder();
                    else if(index == 2) cubit.goToUsers();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: isSelected
                            ? BoxDecoration(
                          color: AppColor.buttonSecondaryColor,
                          borderRadius: BorderRadius.circular(15),
                        )
                            : null,
                        child: Icon(
                          _icons[index],
                          size: 18,
                          color: isSelected
                              ? AppColor.buttonMainColor
                              : Colors.black12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labels[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppColor.buttonMainColor
                              : Colors.black12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}