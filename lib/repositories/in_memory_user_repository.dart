import '../models/user.dart';
import 'user_repository.dart';

class InMemoryUserRepository implements UserRepository {
  final List<UserModel> _users = <UserModel>[];

  @override
  Future<List<UserModel>> getUsers() async {
    // Return a copy of the in‑memory list
    return List<UserModel>.from(_users);
  }

  @override
  Future<void> addUser(UserModel user) async {
    _users.add(user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    _users.removeWhere((u) => u.id == id);
  }
}
