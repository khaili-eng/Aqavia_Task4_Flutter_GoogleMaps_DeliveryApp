import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled18/core/route/app_route.dart';
import 'package:untitled18/features/main/presentation/manager/location_cubit.dart';
import 'package:untitled18/features/user/presentation/view/users_page.dart';


import '../../../../core/hive/hive_service.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_form_feild.dart';
import '../../data/models/user_model.dart';
import '../../repo/user_repo.dart';
import '../manager/user_cubit.dart';
import '../manager/user_state.dart';
import '../usecase/add_user_use_case.dart';
import '../usecase/clear_users_use_case.dart';
import '../usecase/delete_user_use_case.dart';
import '../usecase/get_all_user_use_case.dart';
import '../usecase/update_user_use_case.dart';
import '../widgets/user_card.dart';

class UserPage extends StatelessWidget {
  UserPage({super.key});

  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UserCubit>();
    final hiveService = HiveService();
    final userRepo = UserRepository(hiveService);
    final userBox = hiveService.getBox<UserModel>('users');
    final _formKey = GlobalKey<FormState>();
    return BlocProvider(
      create: (_) => UserCubit(
          addUserUseCase:  AddUserUseCase(userRepo),
          getAllUsersUseCase: GetAllUsersUseCase(userRepo),
          deleteUserUseCase: DeleteUserUseCase(userRepo),
          updateUserUseCase: UpdateUserUseCase(userRepo),
          clearUsersUseCase: ClearUsersUseCase(userRepo)),
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 4,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          title: const Text(
            'Hive + Cubit',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () {
                cubit.loadUsers();
              },
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            cubit.clearUsers();
          },
          label: const Text('Clear All Users'),
          icon: const Icon(Icons.delete_forever),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4)
              )]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
               AppTextFormFeild(
                   controller: nameController,
                   label: 'Name',
                   icon: Icons.person),
                SizedBox(height: 12,),
               AppTextFormFeild(
                   controller: emailController,
                   label: 'Email',
                   icon: Icons.email_outlined),
                SizedBox(height: 12,),
               AppTextFormFeild(
                 controller: passwordController,
                 label: 'Password',
                 icon: Icons.key),
                const SizedBox(height: 16),
                 AppPrimaryButton(
                 text: 'Add User',
                 onPressed: (){
                   if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Please fill all fields')),
                   );
                return;
                 }
                   final user = UserModel(
                     id: DateTime.now().millisecondsSinceEpoch.toString(),
                     name: nameController.text,
                     email: emailController.text,
                     password: passwordController.text,
                   );

                   context.read<UserCubit>().addUser(user);
                   final hiveService = HiveService();
                   final userBox = hiveService.getBox<UserModel>('users');
                   userBox.add(user);


                   nameController.clear();
                   emailController.clear();
                   passwordController.clear();
                  context.read<NavigationCubit>().goToUsers();
                  context.goNamed('users');
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('User added successfully')),
                   );

                 },
                ),
                const SizedBox(height: 16),




              ],
            ),
          ),
        ),
      ),
    );
  }
}
