

import '../../repo/user_repo.dart';

class DeleteUserUseCase{
  final UserRepository userRepo;
  DeleteUserUseCase(this.userRepo);
  Future<void> call(String id)async{
    await userRepo.deleteUser(id);
  }
}