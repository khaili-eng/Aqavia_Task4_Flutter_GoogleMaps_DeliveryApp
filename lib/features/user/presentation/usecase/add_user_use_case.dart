

import '../../data/models/user_model.dart';
import '../../repo/user_repo.dart';

class AddUserUseCase{
  final UserRepository userRepo;
  AddUserUseCase(this.userRepo);
  Future<void> call(UserModel user)async{
    await userRepo.addUser(user);
  }
}