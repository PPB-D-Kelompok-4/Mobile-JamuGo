import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_jamugo/widgets/file_picker.dart';
import 'package:mobile_jamugo/widgets/submit_button.dart';
import 'package:mobile_jamugo/widgets/text_field.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:mobile_jamugo/api/menu/menu.dart';

class AddMenuPage extends StatefulWidget {
  final Function onMenuCreated;

  const AddMenuPage({super.key, required this.onMenuCreated});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  File? _image;

  void showToast(BuildContext context, String message, bool isSuccess) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_image != null) {
        final File imageFile = File(_image!.path);
        final MenuResponse response = await MenuApi.createMenu(
          name: nameController.text,
          description: descriptionController.text,
          price: double.parse(priceController.text),
          imageFile: imageFile,
        );
        if (response.isSuccess) {
          widget.onMenuCreated();
          GoRouter.of(context).pop();
        }
        showToast(context, response.message, response.isSuccess);
      } else {
        showToast(context, "Please select an image", false);
      }
    }
  }

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Menu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFieldWidget(
                  label: 'Name',
                  controller: nameController,
                  validator: FormValidation.requiredTextField,
                ),
                const SizedBox(height: 20.0),
                TextFieldWidget(
                  label: 'Description',
                  controller: descriptionController,
                  validator: FormValidation.requiredTextField,
                ),
                const SizedBox(height: 20.0),
                TextFieldWidget(
                  label: 'Price',
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  validator: FormValidation.requiredTextField,
                ),
                const SizedBox(height: 20.0),
                ImagePickerWidget(
                  image: _image,
                  getImage: getImage,
                ),
                const SizedBox(height: 40.0),
                SubmitButton(onPressed: _submitForm, buttonText: 'Create'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
