import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../usecase/add_user_use_case.dart';
import '../usecase/clear_users_use_case.dart';
import '../usecase/delete_user_use_case.dart';
import '../usecase/get_all_user_use_case.dart';
import '../usecase/update_user_use_case.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final AddUserUseCase addUserUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final ClearUsersUseCase clearUsersUseCase;
//is injection right?
  //constracter injection with more than dependence
  UserCubit({
    required this.addUserUseCase,
    required this.getAllUsersUseCase,
    required this.deleteUserUseCase,
    required this.updateUserUseCase,
    required this.clearUsersUseCase,
  }) : super(UserInitial()) {
    loadUsers();
  }

  void loadUsers() {
    try {
      final users = getAllUsersUseCase();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> addUser(UserModel user) async {
    emit(UserLoading());
    try {
      await addUserUseCase(user);
     loadUsers();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> deleteUser(String id) async {
    emit(UserLoading());
    try {
      await deleteUserUseCase(id);
      loadUsers();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
Future<void> updateUser(UserModel user) async{
    emit(UserLoading());
    try{
        await updateUserUseCase(user);
        loadUsers();
    }catch(e){
      emit(UserError(e.toString()));
    }
    }
Future<void> clearUsers()async{
    emit(UserLoading());
    try{
      await clearUsersUseCase();
      loadUsers();
    }catch(e){
emit(UserError(e.toString()));
    }
}
}

