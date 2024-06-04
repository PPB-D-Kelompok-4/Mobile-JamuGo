import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamugo/api/profile/profile.dart';
import 'package:jamugo/utils/secure_storage.dart';

class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({super.key});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();

  File? _networkProfileImage;
  int? _pkid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ProfileApi.getUserData();

      setState(() {
        _nameController.text = userData.name;
        _addressController.text = userData.address;
        _emailController.text = userData.email;
        _roleController.text = userData.role;
        _pkid = userData.pkid;
      });

      if (userData.imageProfile != null) {
        final imageFile = await ProfileApi.getUserImage(userData.imageProfile!);
        setState(() {
          _networkProfileImage = imageFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data')),
      );
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
              onTap: null,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.green[100],
                    backgroundImage: _networkProfileImage != null
                        ? FileImage(_networkProfileImage!)
                        : null,
                    child: _networkProfileImage == null
                        ? Icon(Icons.person, size: 80, color: Colors.grey[600])
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildProfileView(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
              GoRouter.of(context).go('/profile/edit');
            },
                child: Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    ),
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
        _buildProfileInfo('Role', _roleController.text),
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
}
