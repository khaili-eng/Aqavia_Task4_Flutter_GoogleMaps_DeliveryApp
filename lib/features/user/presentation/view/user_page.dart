import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/hive/hive_service.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_form_feild.dart';
import '../../../main/presentation/manager/location_cubit.dart';
import '../../data/models/user_model.dart';
import '../../repo/user_repo.dart';
import '../manager/user_cubit.dart';
import '../manager/user_state.dart';
import '../usecase/add_user_use_case.dart';
import '../usecase/clear_users_use_case.dart';
import '../usecase/delete_user_use_case.dart';
import '../usecase/get_all_user_use_case.dart';
import '../usecase/update_user_use_case.dart';

class UserPage extends StatelessWidget {
  UserPage({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final hiveService = HiveService();
    final userRepo = UserRepository(hiveService);


    return BlocProvider(
      create: (_) => UserCubit(
        addUserUseCase: AddUserUseCase(userRepo),
        getAllUsersUseCase: GetAllUsersUseCase(userRepo),
        deleteUserUseCase: DeleteUserUseCase(userRepo),
        updateUserUseCase: UpdateUserUseCase(userRepo),
        clearUsersUseCase: ClearUsersUseCase(userRepo),
      )..loadUsers(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          centerTitle: true,
          title: const Text(
            'User Page',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                context.read<UserCubit>().loadUsers();
              },
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          icon: const Icon(Icons.delete_forever),
          label: const Text('Clear All Users'),
          onPressed: () {
            context.read<UserCubit>().clearUsers();
          },
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),

            child: BlocConsumer<UserCubit, UserState>(
              listener: (context, state) {
                if (state is UserLoaded) {
                  nameController.clear();
                  emailController.clear();
                  passwordController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User added successfully'),
                    ),
                  );

                  context.read<NavigationCubit>().goToUsers();
                  context.goNamed('users');
                }

                if (state is UserError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },

              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextFormFeild(
                      controller: nameController,
                      label: 'Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),

                    AppTextFormFeild(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),

                    AppTextFormFeild(
                      controller: passwordController,
                      label: 'Password',
                      icon: Icons.key,
                    ),
                    const SizedBox(height: 16),

                    AppPrimaryButton(
                      text: state is UserLoading
                          ? 'Loading...'
                          : 'Add User',
                      onPressed: () {
                        if (state is UserLoading) return;

                        if (nameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('Please fill all fields'),
                            ),
                          );
                          return;
                        }

                        final user = UserModel(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        context.read<UserCubit>().addUser(user);

                        context.read<NavigationCubit>().goToUsers(); context.goNamed('users');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}