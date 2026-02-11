import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';


import 'package:untitled18/features/main/presentation/manager/location_cubit.dart';

import 'package:untitled18/features/user/presentation/view/user_page.dart';

import 'core/route/app_route.dart';
import 'features/delivery/presentation/manager/delivery_cubit.dart';
import 'features/user/data/models/user_model.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await Hive.initFlutter();
  await Hive.openBox<UserModel>('users');
  Hive.registerAdapter(UserModelAdapter());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MultiBlocProvider(
           providers: [
             BlocProvider(create: (_)=>LocationCubit()),
             BlocProvider(create: (_)=>NavigationCubit()),
             BlocProvider(create: (_) => DeliveryCubit(),),


           ],
      child: MaterialApp.router(

        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.router,
      ),

    );
  }
}
