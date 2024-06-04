import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamugo/api/profile/profile.dart';
import 'package:path_provider/path_provider.dart';


class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();

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

    try {
      await ProfileApi.uploadProfileImage(_localProfileImage!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile image')),
      );
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate() && _pkid != null) {
      try {
        await ProfileApi.updateUserData(_pkid!, _nameController.text, _addressController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated')),
        );
        Navigator.pop(context); // Navigate back to profile view page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updateUserData();
                  _uploadProfileImage();
                  GoRouter.of(context).go('/profile');
                },
                child: Text('Save'),
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
      ),
    );
  }
}
