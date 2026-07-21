import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/in_memory_user_repository.dart';
import '../repositories/user_repository.dart';

class UserState {
  final List<UserModel> items;
  final bool isLoading;

  const UserState({
    this.items = const <UserModel>[],
    this.isLoading = false,
  });

  UserState copyWith({
    List<UserModel>? items,
    bool? isLoading,
  }) {
    return UserState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserViewModel extends StateNotifier<UserState> {
  UserViewModel(this.repository) : super(const UserState(isLoading: true)) {
    loadUsers();
  }

  final UserRepository repository;

  Future<void> loadUsers() async {
    final users = await repository.getUsers();
    state = UserState(items: users, isLoading: false);
  }

  Future<void> addUser({
    required String fullName,
    required String email,
    required String avatar,
  }) async {
    final nextId = state.items.isEmpty ? 1 : (state.items.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1);
    final newUser = UserModel(id: nextId, fullName: fullName, email: email, avatar: avatar);
    await repository.addUser(newUser);
    state = state.copyWith(items: [...state.items, newUser]);
  }

  Future<void> updateUser(UserModel user) async {
    await repository.updateUser(user);
    final updatedItems = state.items.map((u) => u.id == user.id ? user : u).toList();
    state = state.copyWith(items: updatedItems);
  }

  Future<void> deleteUser(int id) async {
    await repository.deleteUser(id);
    final remaining = state.items.where((u) => u.id != id).toList();
    state = state.copyWith(items: remaining);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return InMemoryUserRepository();
});

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserState>((ref) {
  return UserViewModel(ref.watch(userRepositoryProvider));
});
