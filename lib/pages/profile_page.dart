import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:jamugo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  File? _localProfileImage;
  File? _networkProfileImage;
  int? _pkid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = await SecureStorage.readSecureData(key: 'token');
      if (token != null) {
        final response = await Dio().get(
          'http://103.127.132.182:3009/api/user/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        final userData = response.data['data'];

        setState(() {
          _nameController.text = userData['name'];
          _addressController.text = userData['address'];
          _emailController.text = userData['email'];
          _pkid = userData['pkid'];
        });

        if (userData['image_profile'] != null) {
          await _loadProfileImage(userData['image_profile'], token);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  Future<void> _loadProfileImage(String imageProfile, String token) async {
    try {
      final response = await Dio().get(
        'http://103.127.132.182:3009/api/user/profile-image/$imageProfile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$imageProfile');
      await file.writeAsBytes(response.data);

      setState(() {
        _networkProfileImage = file;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile image')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = pickedFile.path.split('/').last;
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      setState(() {
        _localProfileImage = savedImage;
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_localProfileImage == null) return;

    final token = await SecureStorage.readSecureData(key: 'token');
    if (token != null) {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(_localProfileImage!.path),
      });

      try {
        final response = await Dio().post(
          'http://103.127.132.182:3009/api/user/upload-profile-image/',
          data: formData,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        final newImageProfile = response.data['image_profile'];
        await _loadProfileImage(newImageProfile, token);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile image')),
        );
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      final token = await SecureStorage.readSecureData(key: 'token');
      if (token != null && _pkid != null) {
        try {
          await Dio().put(
            'http://103.127.132.182:3009/api/user/$_pkid',
            data: {
              'name': _nameController.text,
              'address': _addressController.text,
            },
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );

          setState(() {
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              SecureStorageUtil.deleteSecureData(key: 'token');
              GoRouter.of(context).go('/landing');
            },
          ),
        ],
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.green[100],
                    backgroundImage: _localProfileImage != null
                        ? FileImage(_localProfileImage!)
                        : _networkProfileImage != null
                        ? FileImage(_networkProfileImage!)
                        : null,
                    child: _localProfileImage == null && _networkProfileImage == null
                        ? Icon(Icons.person, size: 80, color: Colors.grey[600])
                        : null,
                  ),
                  if (_isEditing)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _isEditing ? _buildEditForm() : _buildProfileView(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isEditing) {
                  _updateUserData();
                  _uploadProfileImage();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              child: Text(_isEditing ? 'Save' : 'Edit'),
              style: ElevatedButton.styleFrom(
                // primary: Colors.green,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            GoRouter.of(context).go('/home');
          } else if (index == 1) {
            GoRouter.of(context).go('/order');
          } else if (index == 2) {
            GoRouter.of(context).go('/profile');
          }
        },
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileInfo('Name', _nameController.text),
        _buildProfileInfo('Address', _addressController.text),
        _buildProfileInfo('Role', 'Customer'),
        _buildProfileInfo('Email', _emailController.text),
      ],
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.green, fontSize: 16)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18)),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              fillColor: Colors.green[100],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              fillColor: Colors.green[100],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
