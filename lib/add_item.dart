import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'auth/auth_service.dart';
import 'widgets/button.dart';
import 'display_item.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController _controllerMeals = TextEditingController();
  TextEditingController _controllerDesc = TextEditingController();
  TextEditingController _controllerCalories = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  Uint8List? imageData;
  String? imageBase64;
  final List<String> mealType = ['Breakfast', 'Lunch', 'Snacks', 'Dinner', 'Supper'];
  final databaseRef = FirebaseDatabase.instance.ref("items");
  String? selectedMeal;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Compress image to reduce size
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          imageData = bytes;
          imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get image: $e')),
      );
    }
  }

  Future<void> _saveItem() async {
    Map<String, String> newItem = {
      'meals': selectedMeal ?? '',
      'description': _controllerDesc.text,
      'calories': _controllerCalories.text,
      'image': imageBase64 ?? '',
    };
  }

  void saveToFirebase() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please login to add items"))
      );
      return;
    }

    if (key.currentState!.validate() && imageBase64 != null && selectedMeal != null) {
      // Create a reference to the user's items
      final userItemsRef = databaseRef.child(user.uid);

      userItemsRef.push().set({
        'mealType': selectedMeal,
        'description': _controllerDesc.text,
        'calories': _controllerCalories.text,
        'image': imageBase64,
        'timestamp': ServerValue.timestamp,
        'userId': user.uid
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Item added successfully!"))
        );

        _resetForm();
        // Stay on the same page instead of pushing a new one
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DisplayItem()),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add item: $error"))
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields and add an image"))
      );
    }
  }

  void _resetForm() {
    setState(() {
      _controllerDesc.clear();
      _controllerCalories.clear();
      selectedMeal = null;
      imageData = null;
      imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add food Diary'),
      ),
      body: SingleChildScrollView( // Make the form scrollable
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              FormField<String>(
                validator: (value) {
                  if (selectedMeal == null || selectedMeal!.isEmpty) {
                    return 'Please select a meal type';
                  }
                  return null;
                },
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      errorText: state.hasError ? state.errorText : null,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                    ),
                    isEmpty: selectedMeal == null,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedMeal,
                        hint: Text('Select Meal', style: TextStyle(fontSize: 18)),
                        items: mealType.map((meal) {
                          return DropdownMenuItem(
                            value: meal,
                            child: Text(meal),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMeal = newValue;
                            state.didChange(newValue);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _controllerDesc,
                decoration: InputDecoration(
                  hintText: 'Enter the food description',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the food description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _controllerCalories,
                decoration: InputDecoration(
                  hintText: 'Enter the intake calories (Kcal)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter intake calories (Kcal)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: _pickImage,
                        icon: Icon(Icons.camera_alt_rounded),
                        iconSize: 40.0,
                        tooltip: 'Take Photo or Choose from Gallery',
                      ),
                      Text('Add Photo', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              if (imageData != null) ...[
                SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.memory(
                    imageData!,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
              SizedBox(height: 20),
              CustomButton(
                label: "Submit",
                onPressed: () async {
                  if (key.currentState!.validate()) {
                    await _saveItem();
                    saveToFirebase();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}