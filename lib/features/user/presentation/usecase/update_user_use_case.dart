import '../../data/models/user_model.dart';

import '../../repo/user_repo.dart';

class UpdateUserUseCase {
  final UserRepository userRepo;

  UpdateUserUseCase(this.userRepo);

  Future<void> call(UserModel user) async {
    await userRepo.updateUser(user);
  }
}
