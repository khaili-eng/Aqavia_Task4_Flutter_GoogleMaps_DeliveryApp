
import '../../repo/user_repo.dart';

class ClearUsersUseCase {
  final UserRepository userRepo;

  ClearUsersUseCase(this.userRepo);

  Future<void> call() async {
    await userRepo.clearUsers();
  }
}
