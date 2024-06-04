import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamugo/widgets/file_picker.dart';
import 'package:jamugo/widgets/submit_button.dart';
import 'package:jamugo/widgets/text_field.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:jamugo/api/menu/menu.dart';

class UpdateMenuPage extends StatefulWidget {
  final Menu menu;
  final Function onMenuUpdated;

  const UpdateMenuPage(
      {super.key, required this.menu, required this.onMenuUpdated});

  @override
  State<UpdateMenuPage> createState() => _UpdateMenuPageState();
}

class _UpdateMenuPageState extends State<UpdateMenuPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  File? _image;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.menu.name);
    descriptionController =
        TextEditingController(text: widget.menu.description);
    priceController =
        TextEditingController(text: widget.menu.price.toStringAsFixed(0));
  }

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
      final imageFile = _image != null ? File(_image!.path) : null;
      final response = await MenuApi.updateMenu(
        id: widget.menu.pkid,
        name: nameController.text,
        description: descriptionController.text,
        price: double.parse(priceController.text),
        imageFile: imageFile,
      );
      if (response.isSuccess) {
        widget.onMenuUpdated();
        GoRouter.of(context).pop();
      } else {
        GoRouter.of(context).pop();
      }
      showToast(context, response.message, response.isSuccess);
    } else {
      showToast(context, "Please fill in all fields", false);
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
        title: const Text('Update Menu'),
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
                  initialImageUrl: widget.menu.imageUrl,
                  getImage: getImage,
                ),
                const SizedBox(height: 40.0),
                SubmitButton(onPressed: _submitForm, buttonText: 'Update'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
