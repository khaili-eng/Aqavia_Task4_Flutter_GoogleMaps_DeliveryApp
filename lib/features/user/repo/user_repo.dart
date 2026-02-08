import 'package:hive/hive.dart';
import '../../../core/hive/hive_service.dart';
import '../data/models/user_model.dart';

class UserRepository {
  final HiveService hiveService;

  UserRepository(this.hiveService);
  Box<UserModel> get _box => hiveService.getBox<UserModel>('users');

  Future<void> addUser(UserModel user) async {
    try {
      await _box.put(user.id, user);
    } catch (e) {
      throw Exception('Failed to add user');
    }
  }

  UserModel? getUser(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to get user');
    }
  }

  List<UserModel> getAllUsers() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw Exception('Failed to load users');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _box.put(user.id, user);
    } catch (e) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete user');
    }
  }

  Future<void> clearUsers() async {
    try {
      await _box.clear();
      await _box.compact();
    } catch (e) {
      throw Exception('Failed to clear users');
    }
  }
}
