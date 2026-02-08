import '../../data/models/user_model.dart';

import '../../repo/user_repo.dart';

class GetAllUsersUseCase {
  final UserRepository userRepo;

  GetAllUsersUseCase(this.userRepo);

  List<UserModel> call() {
    return userRepo.getAllUsers();
  }
}
