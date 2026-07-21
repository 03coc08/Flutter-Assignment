import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../viewmodels/user_view_model.dart';
import '../widgets/avatar_image.dart';
import 'user_detail_screen.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarController = TextEditingController();

  UserModel? _editingUser;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User Manager')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth >= constraints.maxHeight;

            // TODO: Landscape hiển thị form bên trái, danh sách 2 cột bên phải.
            // Portrait hiển thị form phía trên, danh sách 1 cột phía dưới.
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  _buildForm(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildUserList(
                      users: state.items,
                      isLandscape: isLandscape,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            key: const Key('input_fullname'),
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              hintText: 'Nhập họ và tên',
              border: OutlineInputBorder(),
            ),
            validator: _validateFullName,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('input_email'),
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'example@gmail.com',
              border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('input_avatar'),
            controller: _avatarController,
            decoration: const InputDecoration(
              labelText: 'Avatar',
              hintText: defaultAvatarPath,
              border: OutlineInputBorder(),
            ),
            validator: _validateAvatar,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  key: const Key('btn_add_user'),
                  onPressed: _handleSubmit,
                  child:
                      Text(_editingUser == null ? 'ADD USER' : 'UPDATE USER'),
                ),
              ),
              if (_editingUser != null) ...<Widget>[
                const SizedBox(width: 8),
                OutlinedButton(
                  key: const Key('btn_cancel_edit'),
                  onPressed: _cancelEdit,
                  child: const Text('CANCEL'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList({
    required List<UserModel> users,
    required bool isLandscape,
  }) {
    // TODO: Portrait dùng 1 cột, landscape dùng 2 cột.
    // Lưu ý: kể cả users rỗng vẫn phải render widget Key('user_list').
    // Không thay bằng Center/Text riêng, vì testcase kiểm tra list rỗng không crash.
    return GridView.builder(
      key: const Key('user_list'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLandscape ? 2 : 1,
        mainAxisExtent: 104,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('user_item_${user.id}'),
            onTap: () => _openDetail(user),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  AvatarImage(
                    key: Key('user_item_avatar_${user.id}'),
                    avatar: user.avatar,
                    radius: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: Key('user_item_edit_${user.id}'),
                    icon: const Icon(Icons.edit),
                    onPressed: () => _startEdit(user),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Sửa',
                  ),
                  IconButton(
                    key: Key('user_item_delete_${user.id}'),
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(user),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Xoá',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Họ và tên không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên tối thiểu 2 ký tự';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    final emailPattern = r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$";
    if (!RegExp(emailPattern).hasMatch(value.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  String? _validateAvatar(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Vui lòng chọn ảnh đại diện';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      if (_editingUser != null) {
        // Clear fields that might hold stale values when editing fails validation
        _fullNameController.clear();
        _avatarController.clear();
        setState(() {});
      }
      return;
    }

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    // Use default avatar if user leaves field empty
    final avatarInput = _avatarController.text.trim();
    final avatar = avatarInput.isEmpty ? defaultAvatarPath : avatarInput;

    if (_editingUser == null) {
      await ref.read(userViewModelProvider.notifier).addUser(
        fullName: fullName,
        email: email,
        avatar: avatar,
      );
    } else {
      final updated = _editingUser!.copyWith(
        fullName: fullName,
        email: email,
        avatar: avatar,
      );
      await ref.read(userViewModelProvider.notifier).updateUser(updated);
    }

    // Reset state after successful save
    setState(() {
      _editingUser = null;
      _formKey.currentState?.reset();
      _fullNameController.clear();
      _emailController.clear();
      _avatarController.clear();
    });
  }

  void _startEdit(UserModel user) {
    setState(() {
      _editingUser = user;
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _avatarController.text = user.avatar ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingUser = null;
      _formKey.currentState?.reset();
      _fullNameController.clear();
      _emailController.clear();
      _avatarController.clear();
    });
  }

  Future<void> _confirmDelete(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('delete_confirm_dialog'),
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá người dùng ${user.fullName}?'),
        actions: [
          TextButton(
            key: const Key('btn_cancel_delete'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            key: const Key('btn_confirm_delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(userViewModelProvider.notifier).deleteUser(user.id);
    }
  }

  void _openDetail(UserModel user) {
    // TODO: Navigator.push sang UserDetailScreen(user: user).
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => UserDetailScreen(user: user),
      ),
    );
  }
}
