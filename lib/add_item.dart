import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
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
  Uint8List? imageData; // Stores image data for display
  String? imageBase64; // Stores image data as a base64 string for SharedPreferences
  final List<String> mealType = ['Breakfast', 'Lunch', 'Snacks', 'Dinner', 'Supper'];
  final databaseRef = FirebaseDatabase.instance.ref("items"); // Firebase Database reference
  String? selectedMeal;

  // Pick an image using FilePicker and convert to base64
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        imageData = result.files.single.bytes;
        imageBase64 = base64Encode(imageData!); // Convert to base64 for storage
      });
    }
  }

  // Save item details to SharedPreferences
  Future<void> _saveItem() async {
    Map<String, String> newItem = {
      'meals': selectedMeal ?? '',
      'description': _controllerDesc.text,
      'calories': _controllerCalories.text,
      'image': imageBase64 ?? '',
    };
  }

  // Save data to Firebase Realtime Database
  void saveToFirebase() {
    if (key.currentState!.validate() && imageBase64 != null && selectedMeal != null) {
      databaseRef.push().set({
        'mealType': selectedMeal,
        'description': _controllerDesc.text,
        'calories': _controllerCalories.text,
        'image': imageBase64 // Store image as Base64 string
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item added successfully!")));
// Clear the form fields
        _controllerMeals.clear();
        _controllerDesc.clear();
        _controllerCalories.clear();
        setState(() {
          selectedMeal = null; // Clear the meal type
          imageData = null; // Clear the displayed image
          imageBase64 = null; // Clear the Base64 image string
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add item: $error")));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and pick an image")));
    }
  }

  // Reset form fields
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
      body: Padding(
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
                      //hintText: 'Select Meal',
                      errorText: state.hasError ? state.errorText : null,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0), // Adjusts padding for a smaller box
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
                            state.didChange(newValue); // Update FormField state
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              TextFormField(
                controller: _controllerDesc,
                decoration: InputDecoration(hintText: 'Enter the food description'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the food description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controllerCalories,
                decoration: InputDecoration(hintText: 'Enter the intake calories (Kcal)'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter intake calories (Kcal)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              IconButton(
                onPressed: _pickImage,
                icon: Icon(Icons.camera_alt_rounded),
                iconSize: 40.0,
                tooltip: 'Pick Image from Computer',
              ),

              if (imageData != null)
                Image.memory(imageData!, height: 100, width: 100), // Display image from bytes
              SizedBox(height: 10),
              CustomButton(
                label: "Submit",
                onPressed: () async {
                  if (key.currentState!.validate()) {
                    await _saveItem();
                    saveToFirebase();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item added')));
                    _resetForm();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DisplayItem()),
                    );
                  }
                },
              ),
              // SizedBox(height: 20),
              // CustomButton(
              //   label: "Sign Out",
              //   onPressed: () async {
              //     await auth.signout();
              //     //goToLogin(context);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
