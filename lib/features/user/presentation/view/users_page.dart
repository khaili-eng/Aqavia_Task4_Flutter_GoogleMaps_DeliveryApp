import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:untitled18/core/color/app_color.dart';
import 'package:untitled18/core/widgets/app_empty_state.dart';

import '../../../../core/hive/hive_service.dart';
import '../../data/models/user_model.dart';
import '../manager/user_cubit.dart';
import '../widgets/user_card.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
     final cubit = context.read<UserCubit>();
    final hiveService = HiveService();
    final userBox = hiveService.getBox<UserModel>('users');

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
          title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
      ),
      body: ValueListenableBuilder(
        valueListenable: userBox.listenable(),
        builder: (context, Box<UserModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: AppEmptyState(
              icon:Icons.person_off_outlined,
              title: 'No Users Yet',
              subtitle: 'Start by adding your first user using the form above.',) );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final user = box.getAt(index)!;
              return UserCard(user: user,
                onEdit: () {
                  nameController.text = user.name;
                  emailController.text = user.email;
                  passwordController.text = user.password;

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Update User'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Name'),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(labelText: 'Password'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            final updatedUser = UserModel(
                              id: user.id,
                              name: nameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            cubit.updateUser(updatedUser);
                            Navigator.pop(context);
                          },
                          child: const Text('Update'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                }, onDelete: () {
                  cubit.deleteUser(user.id);
                },);
            },
          );
        },
      ),
    );
  }
}